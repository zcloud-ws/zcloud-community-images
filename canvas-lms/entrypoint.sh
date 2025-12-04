#!/bin/bash
set -e

log() {
    echo "[Canvas LMS] $1"
}

generate_database_config() {
    log "Generating database configuration..."
    export CANVAS_LMS_POSTGRES_HOST=${DB_HOST:-postgres}
    export CANVAS_LMS_POSTGRES_USER=${DB_USER:-postgres}
    export CANVAS_LMS_POSTGRES_PASSWORD=${DB_PASSWORD}
    export CANVAS_LMS_POSTGRES_DATABASE=${DB_NAME:-canvas_production}
    export CANVAS_LMS_POSTGRES_PORT=${DB_PORT:-5432}
    cat > /opt/canvas/config/database.yml <<EOF
production:
  adapter: ${DB_ADAPTER:-postgresql}
  encoding: utf8
  database: ${DB_NAME:-canvas_production}
  host: ${DB_HOST:-localhost}
  port: ${DB_PORT:-5432}
  username: ${DB_USER:-canvas}
  password: ${DB_PASSWORD}
  timeout: 5000
  queue:
    adapter: ${DB_ADAPTER:-postgresql}
    encoding: utf8
    database: ${DB_QUEUE_NAME:-canvas_queue_production}
    host: ${DB_HOST:-localhost}
    port: ${DB_PORT:-5432}
    username: ${DB_USER:-canvas}
    password: ${DB_PASSWORD}
    timeout: 5000
EOF
}

generate_redis_config() {
    cat > /opt/canvas/config/redis.yml <<EOF
production:
  url: ${REDIS_URL:-redis://redis:6379/0}
EOF
}

generate_cache_config() {
    cat > /opt/canvas/config/cache_store.yml <<EOF
production:
  cache_store: redis_cache_store
  url: ${REDIS_CACHE_URL:-redis://redis:6379/1}
EOF
}

generate_security_config() {
    log "Generating security configuration..."

    cat > /opt/canvas/config/security.yml <<EOF
production:
  encryption_key: ${CANVAS_ENCRYPTION_KEY}
  previous_encryption_keys:
    - ${CANVAS_PREVIOUS_ENCRYPTION_KEYS}
  jwt_encryption_keys:
    - ${CANVAS_JWT_ENCRYPTION_KEYS}
EOF
}

generate_mail_config() {
    log "Generating email configuration..."
    cat > /opt/canvas/config/outgoing_mail.yml <<EOF
production:
  address: ${SMTP_ADDRESS:-localhost}
  port: ${SMTP_PORT:-25}
  user_name: ${SMTP_USERNAME}
  password: ${SMTP_PASSWORD}
  authentication: ${SMTP_AUTH:-plain}
  enable_starttls_auto: ${SMTP_STARTTLS:-true}
  domain: ${SMTP_DOMAIN:-example.com}
  outgoing_address: ${SMTP_FROM:-canvas@example.com}
  default_name: ${SMTP_FROM_NAME:-Canvas LMS}
EOF
}

generate_domain_config() {
    cat > /opt/canvas/config/domain.yml <<EOF
production:
  domain: ${CANVAS_DOMAIN:-http://localhost}
EOF
}

generate_delayed_jobs_config() {
    log "Generating delayed_jobs configuration..."
    cat > /opt/canvas/config/delayed_jobs.yml <<EOF
production:
  workers:
  - queue: canvas_queue
    workers: 2
    max_priority: 10
  - queue: canvas_queue
    workers: 4
default:
  workers:
  - queue: canvas_queue
EOF
}

log "Ensuring config directory exists..."
mkdir -p /opt/canvas/config

[ -f /opt/canvas/config/database.yml ] || generate_database_config
[ -f /opt/canvas/config/redis.yml ] || generate_redis_config
[ -f /opt/canvas/config/security.yml ] || generate_security_config
[ -f /opt/canvas/config/cache_store.yml ] || generate_cache_config
[ -f /opt/canvas/config/outgoing_mail.yml ] || generate_mail_config
[ -f /opt/canvas/config/domain.yml ] || generate_domain_config
[ -f /opt/canvas/config/delayed_jobs.yml ] || generate_delayed_jobs_config

# Ensure ownership
chown -R canvaslms:canvaslms /opt/canvas/config

log "Configuring persistence directories..."
mkdir -p /opt/canvas/data/uploads /opt/canvas/data/tmp /opt/canvas/data/log

mkdir -p /opt/canvas/public /opt/canvas/tmp

if [ -e /opt/canvas/public/files ] && [ ! -L /opt/canvas/public/files ]; then
    rm -rf /opt/canvas/public/files
fi
ln -sfn /opt/canvas/data/uploads /opt/canvas/public/files

if [ -e /opt/canvas/tmp/files ] && [ ! -L /opt/canvas/tmp/files ]; then
    rm -rf /opt/canvas/tmp/files
fi
ln -sfn /opt/canvas/data/tmp /opt/canvas/tmp/files

chown -R canvaslms:canvaslms /opt/canvas/data

case "$1" in
    app:start)
        log "Starting Canvas LMS..."
        runuser -u canvaslms -- bash -lc "cd /opt/canvas && npx gulp rev"
        # Optionally run the interactive initial setup (creates DB schema + seed + admin)
        # Enable by setting RUN_INITIAL_SETUP=true and provide:
        #   CANVAS_LMS_ADMIN_EMAIL, CANVAS_LMS_ADMIN_PASSWORD, CANVAS_LMS_ACCOUNT_NAME, CANVAS_LMS_STATS_COLLECTION
        if [ "${RUN_INITIAL_SETUP}" = "true" ]; then
            log "Running Canvas initial setup..."
            runuser -u canvaslms -- bash -lc "cd /opt/canvas && RAILS_ENV=production bundle exec rake db:initial_setup"
        fi
        runuser -u canvaslms -- bash -lc "cd /opt/canvas && bundle exec rake db:migrate"
        runuser -u canvaslms -- bash -lc "cd /opt/canvas && RAILS_GROUPS=assets RAILS_ENV=production bundle exec rake canvas:compile_assets"
        exec nginx -g 'daemon off;' &
        runuser -u canvaslms -- bash -lc "cd /opt/canvas && bundle exec rails server -b 0.0.0.0 -e production -p 3000"
        ;;

    jobs:start)
        log "Starting Canvas Jobs..."
        exec runuser -u canvaslms -- bash -lc "cd /opt/canvas && bundle exec script/delayed_job run"
        ;;

    *)
        log "Executing custom command: $@"
        exec runuser -u canvaslms -- "$@"
        ;;
esac