#!/usr/bin/env bash
set -e

# Shell tracing writes to stderr, so it shows up as errors in the app logs on
# every start. Set STARTUP_TRACE=true to turn it on while debugging startup.
if [ "${STARTUP_TRACE}" == "true" ]; then
  set -x
fi

BUNDLE_FILE=${BUNDLE_FILE:-"/bundle/bundle.tar.gz"}
APP_DIR=${APP_DIR:-"$HOME/app"}
RUN_NPM_INSTALL=${RUN_NPM_INSTALL:-"false"}

if [ -f "${BUNDLE_FILE}" ]; then
  mkdir "$APP_DIR"
  GROUP="$(id -gn)"
  tar -xzf "${BUNDLE_FILE}" -C "$APP_DIR" --strip 1 --group="$GROUP" --owner="$USER"
fi

if [ -f "${APP_DIR}/programs/server/package.json" ] && [ "${RUN_NPM_INSTALL}" == "true" ] ; then
  cd "${APP_DIR}/programs/server/" && npm install --unsafe-perm && cd -
fi

export PORT=${PORT:-3000}
if [ -f "/built_app/main.js" ]; then
  cd /built_app
  exec node main.js
else
  if [ -f "${APP_DIR}/main.js" ]; then
    cd "${APP_DIR}"
    exec node main.js
  fi
fi
