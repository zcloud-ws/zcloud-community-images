#!/usr/bin/env bash
set -e

METEOR_VERSION=${1}

if [ "x${METEOR_VERSION}" == "x" ]; then
  echo Inform the Meteor version to build.
  exit 1
fi

echo "Meteor versions: ${METEOR_VERSION}"

BASE_DIR=$PWD
DIRS="meteor-build meteor-node-runtime meteor-node-mongodb-runtime"

for DIR in $DIRS; do
  echo "Pushing ${DIR}..."
  cd "${DIR}"
  ./push.sh "${METEOR_VERSION}"
  cd "${BASE_DIR}"
  echo "Pushed ${DIR}"
done
