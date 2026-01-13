#!/bin/sh

CONFIG_PATH="/etc/otelcol/config.yaml"

if [ -z "$OTEL_CONFIG_CONTENT" ]; then
    echo "Error: OTEL_CONFIG_CONTENT environment variable is not set."
    exit 1
fi

echo "$OTEL_CONFIG_CONTENT" > "$CONFIG_PATH"

echo "Otel Collector (Alpine) configuration created at $CONFIG_PATH"

exec /usr/bin/otelcol --config="$CONFIG_PATH"