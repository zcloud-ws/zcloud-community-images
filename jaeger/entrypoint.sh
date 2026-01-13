#!/bin/sh

JAEGER_USER=${JAEGER_USER:-admin}
JAEGER_PASSWORD=${JAEGER_PASSWORD:-jaeger123}

htpasswd -bc /etc/nginx/.htpasswd "$JAEGER_USER" "$JAEGER_PASSWORD"

nginx

exec /go/bin/all-in-one-linux