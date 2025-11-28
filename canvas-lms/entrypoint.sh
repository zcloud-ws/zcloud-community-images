#!/bin/bash
set -e

# Function for logging
log() {
    echo "[Canvas LMS] $1"
}

# Function to generate database.yml from environment variables
generate_database_config() {
    log "Generating database configuration..."

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

# Function to generate redis.yml
generate_redis_config() {
    log "Generating Redis configuration..."

    cat > /opt/canvas/config/redis.yml <<EOF
production:
  - ${REDIS_URL:-redis://localhost:6379/0}
EOF
}

# Function to generate cache_store.yml
generate_cache_config() {
    log "Generating cache configuration..."

    cat > /opt/canvas/config/cache_store.yml <<EOF
production:
  cache_store: redis_cache_store
  redis:
    url: ${REDIS_CACHE_URL:-redis://localhost:6379/1}
EOF
}

# Function to generate security.yml
generate_security_config() {
    log "Generating security configuration..."

    # Generate encryption_key if not provided
    if [ -z "$CANVAS_ENCRYPTION_KEY" ]; then
        CANVAS_ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
        log "WARNING: encryption_key generated automatically. Save this key: $CANVAS_ENCRYPTION_KEY"
    fi

    cat > /opt/canvas/config/security.yml <<EOF
production:
  encryption_key: ${CANVAS_ENCRYPTION_KEY}
  signing_secret: ${CANVAS_SIGNING_SECRET:-$(head -c 32 /dev/urandom | base64)}
  lti_iss: ${CANVAS_LTI_ISS:-https://canvas.example.com}
EOF
}

# Function to generate outgoing_mail.yml
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

# Function to generate domain.yml
generate_domain_config() {
    log "Generating domain configuration..."

    cat > /opt/canvas/config/domain.yml <<EOF
production:
  domain: ${CANVAS_DOMAIN:-localhost}
  ssl: ${CANVAS_SSL:-false}
  files_domain: ${CANVAS_FILES_DOMAIN:-${CANVAS_DOMAIN:-localhost}}
EOF
}

# Function to generate delayed_jobs.yml
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

# Check if this is first run
if [ ! -f /opt/canvas/config/database.yml ]; then
    log "First run detected. Generating configuration files..."

    # Generate all configuration files
    generate_database_config
    generate_redis_config
    generate_cache_config
    generate_security_config
    generate_mail_config
    generate_domain_config
    generate_delayed_jobs_config

    # Fix permissions
    chown -R canvas:canvas /opt/canvas/config
fi

# Create symlinks for persistence volume
log "Configuring persistence directories..."
mkdir -p /opt/canvas/data/uploads /opt/canvas/data/tmp /opt/canvas/data/log

if [ ! -L /opt/canvas/public/files ]; then
    ln -sf /opt/canvas/data/uploads /opt/canvas/public/files
fi

if [ ! -L /opt/canvas/tmp/files ]; then
    rm -rf /opt/canvas/tmp/files
    ln -sf /opt/canvas/data/tmp /opt/canvas/tmp/files
fi

# Fix permissions
chown -R canvas:canvas /opt/canvas/data

# Process command
case "$1" in
    app:start)
        log "Starting Canvas LMS..."

        # Run migrations if requested
        if [ "$RUN_MIGRATIONS" = "true" ]; then
            log "Running migrations..."
            su -s /bin/bash canvas -c "cd /opt/canvas && bundle exec rake db:migrate"
        fi

        # Compile assets if requested
        if [ "$COMPILE_ASSETS" = "true" ]; then
            log "Compiling assets..."
            su -s /bin/bash canvas -c "cd /opt/canvas && bundle exec rake canvas:compile_assets"
        fi

        # Start application
        log "Starting Rails server..."
        exec su -s /bin/bash canvas -c "cd /opt/canvas && bundle exec rails server -b 0.0.0.0 -p 3000"
        ;;

    jobs:start)
        log "Starting Canvas Jobs..."
        exec su -s /bin/bash canvas -c "cd /opt/canvas && bundle exec script/delayed_job run"
        ;;

    console)
        log "Starting Rails console..."
        exec su -s /bin/bash canvas -c "cd /opt/canvas && bundle exec rails console"
        ;;

    bash|shell)
        log "Starting shell..."
        exec su -s /bin/bash canvas
        ;;

    *)
        log "Executing custom command: $@"
        exec "$@"
        ;;
esac
