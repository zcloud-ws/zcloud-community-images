#!/usr/bin/env bash

BUNDLE_FILE="/bundle/bundle.tar.gz"
APP_DIR="$HOME/app"

if [ -f "${BUNDLE_FILE}" ]; then
  mkdir "$APP_DIR"
  GROUP="$(id -gn)"
  tar -xzf "${BUNDLE_FILE}" -C "$APP_DIR" --strip 1 --group="$GROUP" --owner="$USER"
fi

if [ -f "${APP_DIR}/programs/server/package.json" ]; then
  cd "${APP_DIR}/programs/server/" && npm install --unsafe-perm && cd -
fi

if [ -f "/built_app/main.js" ]; then
  cd /built_app
  node main.js
else
  if [ -f "${APP_DIR}/main.js" ]; then
    cd "${APP_DIR}"
    node main.js
  fi
fi
