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

if [ "x${USE_INTERNAL_MONGODB}" != "x" ]; then
  MONGODB_DATA_DIR=${MONGODB_DATA_DIR:-/mongodb-data}
  MONGODB_EXEC="mongod --dbpath ${MONGODB_DATA_DIR} --bind_ip 0.0.0.0 --syslog --port 27017 --fork ${MONGODB_EXTRA_ARGS}"
  echo "Starting internal mongodb on port 27017 ..."
  ${MONGODB_EXEC}
  echo "Mongodb started."
  if [ "x${MONGO_URL}" == "x" ]; then
    export MONGO_URL=mongodb://localhost:27017/app
  fi
fi

export PORT=${PORT:-3000}
if [ -f "/built_app/main.js" ]; then
  echo "Starting app on port :$PORT ..."
  cd /built_app
  node main.js
else
  if [ -f "${APP_DIR}/main.js" ]; then
    echo "Starting app on port :$PORT ..."
    cd "${APP_DIR}"
    node main.js
  fi
fi