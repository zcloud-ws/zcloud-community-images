#!/usr/bin/env bash
set -euo pipefail

readonly DEFAULT_DATA_DIR="/opt/broadcast"
readonly DEFAULT_PROJECT_NAME="broadcast"
readonly LICENSE_CHECK_URL="https://sendbroadcast.net/license/check"

log() {
  printf '[broadcast-launcher] %s\n' "$*"
}

fail() {
  printf '[broadcast-launcher] ERROR: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

require_env() {
  local name="$1"
  if [ -z "${!name:-}" ]; then
    fail "Missing required environment variable: $name"
  fi
}

check_docker_access() {
  require_command docker
  docker version >/dev/null 2>&1 || fail "Docker is not reachable. Mount the Docker socket, for example: -v /var/run/docker.sock:/var/run/docker.sock"
  docker compose version >/dev/null 2>&1 || fail "docker compose is not available in this image"
}

prepare_directories() {
  mkdir -p \
    "$BROADCAST_DATA_DIR/app/storage" \
    "$BROADCAST_DATA_DIR/app/uploads" \
    "$BROADCAST_DATA_DIR/app/triggers" \
    "$BROADCAST_DATA_DIR/app/monitor" \
    "$BROADCAST_DATA_DIR/db/backups" \
    "$BROADCAST_DATA_DIR/db/init-scripts" \
    "$BROADCAST_DATA_DIR/db/postgres-data" \
    "$BROADCAST_DATA_DIR/logs" \
    "$BROADCAST_DATA_DIR/ssl"
}

validate_license() {
  require_command curl
  require_command jq
  require_env BROADCAST_DOMAIN
  require_env BROADCAST_LICENSE_KEY

  local response_file http_code registry_url registry_login registry_password
  response_file=$(mktemp)

  log "Validating Broadcast license for ${BROADCAST_DOMAIN}"
  http_code=$(curl -sS -w '%{http_code}' -o "$response_file" \
    -X POST \
    -H 'Content-Type: application/json' \
    -d "$(jq -nc --arg key "$BROADCAST_LICENSE_KEY" --arg domain "$BROADCAST_DOMAIN" '{key:$key, domain:$domain}')" \
    "$LICENSE_CHECK_URL")

  if [ "$http_code" = "401" ]; then
    rm -f "$response_file"
    fail "Broadcast rejected the license key for ${BROADCAST_DOMAIN}"
  fi

  if [ "$http_code" != "200" ]; then
    local body
    body=$(cat "$response_file")
    rm -f "$response_file"
    fail "Broadcast license check returned HTTP ${http_code}: ${body}"
  fi

  jq empty "$response_file" >/dev/null 2>&1 || {
    rm -f "$response_file"
    fail "Broadcast license check did not return valid JSON"
  }

  registry_url=$(jq -r '.registry_url // empty' "$response_file")
  registry_login=$(jq -r '.registry_login // empty' "$response_file")
  registry_password=$(jq -r '.registry_password // empty' "$response_file")
  rm -f "$response_file"

  [ -n "$registry_url" ] || fail "Broadcast license response did not include registry_url"
  [ -n "$registry_login" ] || fail "Broadcast license response did not include registry_login"
  [ -n "$registry_password" ] || fail "Broadcast license response did not include registry_password"

  BROADCAST_REGISTRY_URL="$registry_url"
  BROADCAST_REGISTRY_LOGIN="$registry_login"
  BROADCAST_REGISTRY_PASSWORD="$registry_password"
  export BROADCAST_REGISTRY_URL BROADCAST_REGISTRY_LOGIN BROADCAST_REGISTRY_PASSWORD

  log "Broadcast license validated"
}

resolve_broadcast_image() {
  if [ -n "${BROADCAST_IMAGE:-}" ]; then
    export BROADCAST_IMAGE
    return
  fi

  local version image_name arch
  version="${BROADCAST_VERSION:-latest}"
  arch="$(uname -m)"
  image_name="broadcast"

  case "$arch" in
    aarch64|arm64)
      image_name="broadcast-arm"
      export TARGETARCH="arm64"
      ;;
    *)
      export TARGETARCH="amd64"
      ;;
  esac

  BROADCAST_IMAGE="${BROADCAST_REGISTRY_URL}/broadcast/${image_name}:${version}"
  export BROADCAST_IMAGE
}

write_env_files() {
  local app_env="$BROADCAST_DATA_DIR/app/.env"
  local db_env="$BROADCAST_DATA_DIR/db/.env"
  local postgres_user postgres_password

  postgres_user="${POSTGRES_USER:-broadcast}"

  if [ -f "$db_env" ]; then
    # shellcheck disable=SC1090
    source "$db_env"
    postgres_password="${POSTGRES_PASSWORD:?POSTGRES_PASSWORD missing from existing db/.env}"
  else
    postgres_password="${POSTGRES_PASSWORD:-$(openssl rand -hex 16)}"
  fi

  if [ ! -f "$app_env" ]; then
    log "Creating app environment file at ${app_env}"
    cat > "$app_env" <<APP_ENV
RAILS_ENV=production
SECRET_KEY_BASE=${SECRET_KEY_BASE:-$(openssl rand -hex 64)}
DATABASE_HOST=postgres
DATABASE_USERNAME=${postgres_user}
DATABASE_PASSWORD=${postgres_password}
STORAGE_PATH=/rails/ssl
TLS_DOMAIN=${BROADCAST_DOMAIN}
LICENSE_KEY=${BROADCAST_LICENSE_KEY}
BROADCAST_MANAGED=true
ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=${ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY:-$(openssl rand -hex 16)}
ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=${ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY:-$(openssl rand -hex 16)}
ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=${ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT:-$(openssl rand -hex 16)}
APP_ENV
  else
    log "Using existing app environment file at ${app_env}"
  fi

  if [ ! -f "$db_env" ]; then
    log "Creating database environment file at ${db_env}"
    cat > "$db_env" <<DB_ENV
POSTGRES_USER=${postgres_user}
POSTGRES_PASSWORD=${postgres_password}
POSTGRES_MULTIPLE_DATABASES=broadcast_primary_production,broadcast_queue_production,broadcast_cable_production
DB_ENV
  else
    log "Using existing database environment file at ${db_env}"
  fi

  printf '%s\n' "$BROADCAST_DOMAIN" > "$BROADCAST_DATA_DIR/.domain"
  printf '%s\n' "$BROADCAST_IMAGE" > "$BROADCAST_DATA_DIR/.image"
}

write_compose_file() {
  local compose_file="$BROADCAST_DATA_DIR/docker-compose.yml"
  local http_port https_port postgres_port

  http_port="${BROADCAST_HTTP_PORT:-80}"
  https_port="${BROADCAST_HTTPS_PORT:-443}"
  postgres_port="${BROADCAST_POSTGRES_PORT:-127.0.0.1:5432}"

  cat > "$compose_file" <<COMPOSE
services:
  app:
    image: ${BROADCAST_IMAGE}
    platform: linux/${TARGETARCH:-amd64}
    pull_policy: always
    restart: always
    env_file:
      - ${BROADCAST_DATA_DIR}/app/.env
    volumes:
      - ${BROADCAST_DATA_DIR}/app/storage:/rails/storage
      - ${BROADCAST_DATA_DIR}/app/uploads:/rails/uploads
      - ${BROADCAST_DATA_DIR}/app/triggers:/rails/triggers
      - ${BROADCAST_DATA_DIR}/app/monitor:/rails/monitor
      - ${BROADCAST_DATA_DIR}/ssl:/rails/ssl
      - ${BROADCAST_DATA_DIR}/logs:/rails/logs
    ports:
      - "${http_port}:80"
      - "${https_port}:443"
    networks:
      - broadcast-network
    depends_on:
      postgres:
        condition: service_healthy
    logging:
      driver: json-file
      options:
        max-size: 10m
        max-file: "3"

  job:
    image: ${BROADCAST_IMAGE}
    platform: linux/${TARGETARCH:-amd64}
    pull_policy: always
    restart: always
    env_file:
      - ${BROADCAST_DATA_DIR}/app/.env
    volumes:
      - ${BROADCAST_DATA_DIR}/app/storage:/rails/storage
      - ${BROADCAST_DATA_DIR}/app/uploads:/rails/uploads
    networks:
      - broadcast-network
    depends_on:
      postgres:
        condition: service_healthy
    command:
      - bin/jobs
    logging:
      driver: json-file
      options:
        max-size: 10m
        max-file: "3"

  postgres:
    image: postgres:17-alpine
    restart: always
    env_file:
      - ${BROADCAST_DATA_DIR}/db/.env
    volumes:
      - ${BROADCAST_DATA_DIR}/db/backups:/backups
      - ${BROADCAST_DATA_DIR}/db/postgres-data:/var/lib/postgresql/data
      - ${BROADCAST_DATA_DIR}/db/init-scripts:/docker-entrypoint-initdb.d
    ports:
      - "${postgres_port}:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U broadcast"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 30s
    networks:
      - broadcast-network
    logging:
      driver: json-file
      options:
        max-size: 10m
        max-file: "3"

networks:
  broadcast-network:
    driver: bridge
COMPOSE
}

docker_login_to_broadcast_registry() {
  log "Logging in to Broadcast registry ${BROADCAST_REGISTRY_URL}"
  printf '%s' "$BROADCAST_REGISTRY_PASSWORD" | docker login "$BROADCAST_REGISTRY_URL" \
    --username "$BROADCAST_REGISTRY_LOGIN" \
    --password-stdin >/dev/null
}

install_broadcast() {
  check_docker_access
  validate_license
  resolve_broadcast_image
  prepare_directories
  write_env_files
  write_compose_file
  docker_login_to_broadcast_registry

  log "Pulling and starting Broadcast containers with image ${BROADCAST_IMAGE}"
  docker compose \
    --project-name "$BROADCAST_PROJECT_NAME" \
    -f "$BROADCAST_DATA_DIR/docker-compose.yml" \
    up -d --pull always

  log "Broadcast containers started. Open https://${BROADCAST_DOMAIN} after DNS points to this Docker host."
}

show_status() {
  check_docker_access
  docker compose \
    --project-name "$BROADCAST_PROJECT_NAME" \
    -f "$BROADCAST_DATA_DIR/docker-compose.yml" \
    ps
}

show_logs() {
  check_docker_access
  docker compose \
    --project-name "$BROADCAST_PROJECT_NAME" \
    -f "$BROADCAST_DATA_DIR/docker-compose.yml" \
    logs -f --tail "${BROADCAST_LOG_TAIL:-100}"
}

stop_broadcast() {
  check_docker_access
  docker compose \
    --project-name "$BROADCAST_PROJECT_NAME" \
    -f "$BROADCAST_DATA_DIR/docker-compose.yml" \
    down
}

print_help() {
  cat <<HELP
Broadcast Docker launcher for licensed customers.

This public image does not include Broadcast software. It validates the customer
license at runtime, logs in to Broadcast's registry, and starts the official
Broadcast containers on the Docker host.

Commands:
  install   Validate license, write config, pull images, and start Broadcast.
  status    Show Broadcast compose status.
  logs      Follow Broadcast compose logs.
  stop      Stop Broadcast compose services.
  help      Show this help.

Required for install:
  BROADCAST_DOMAIN       Primary installation domain, for example broadcast.example.com.
  BROADCAST_LICENSE_KEY  Customer's Broadcast license key.

Optional:
  BROADCAST_VERSION       Broadcast version tag. Default: latest.
  BROADCAST_IMAGE         Full official Broadcast image. Overrides BROADCAST_VERSION.
  BROADCAST_DATA_DIR      Host-mounted data/config directory. Default: /opt/broadcast.
  BROADCAST_PROJECT_NAME  Docker Compose project name. Default: broadcast.
  BROADCAST_HTTP_PORT     Host HTTP port. Default: 80.
  BROADCAST_HTTPS_PORT    Host HTTPS port. Default: 443.

Example:
  docker run --rm \\
    -v /var/run/docker.sock:/var/run/docker.sock \\
    -v /opt/broadcast:/opt/broadcast \\
    -e BROADCAST_DOMAIN=broadcast.example.com \\
    -e BROADCAST_LICENSE_KEY=xxxxx-xxxxx-xxxxx-xx \\
    zcloudws/broadcast:1.0.0 install
HELP
}

main() {
  BROADCAST_DATA_DIR="${BROADCAST_DATA_DIR:-$DEFAULT_DATA_DIR}"
  BROADCAST_PROJECT_NAME="${BROADCAST_PROJECT_NAME:-$DEFAULT_PROJECT_NAME}"
  export BROADCAST_DATA_DIR BROADCAST_PROJECT_NAME

  local command="${1:-install}"
  case "$command" in
    install|up)
      install_broadcast
      ;;
    status|ps)
      show_status
      ;;
    logs)
      show_logs
      ;;
    stop|down)
      stop_broadcast
      ;;
    help|--help|-h)
      print_help
      ;;
    *)
      fail "Unknown command: ${command}. Run 'help' for usage."
      ;;
  esac
}

main "$@"
