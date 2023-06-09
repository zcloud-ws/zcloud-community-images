#!/usr/bin/env bash
set -e -x

BUNDLE_FILE=${BUNDLE_FILE:-"/bundle/bundle.tar.gz"}
APP_DIR=${APP_DIR:-"$HOME/app"}
NO_NPM_INSTALL=${NO_NPM_INSTALL}

if [ -f "${BUNDLE_FILE}" ]; then
  mkdir "$APP_DIR"
  GROUP="$(id -gn)"
  tar -xzf "${BUNDLE_FILE}" -C "$APP_DIR" --strip 1 --group="$GROUP" --owner="$USER"
fi

if [ -f "${APP_DIR}/programs/server/package.json" ] && [ "x${NO_NPM_INSTALL}" == "x" ] ; then
  cd "${APP_DIR}/programs/server/" && npm install --unsafe-perm && cd -
fi

export PORT=${PORT:-3000}
if [ -f "/built_app/main.js" ]; then
  cd /built_app
  node main.js
else
  if [ -f "${APP_DIR}/main.js" ]; then
    cd "${APP_DIR}"
    node main.js
  fi
fi
