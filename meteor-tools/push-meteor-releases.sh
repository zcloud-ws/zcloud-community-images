#!/usr/bin/env bash
set -e -x

source releases.sh
BASE_DIR=$PWD
DIRS="meteor-build meteor-node-runtime meteor-node-mongodb-runtime"

for METEOR_VERSION in ${RELEASES}; do
  echo "Meteor versions: ${METEOR_VERSION}"
  for DIR in $DIRS; do
    cd "${DIR}" || exit
    ./push.sh "${METEOR_VERSION}" || true
    cd "${BASE_DIR}" || exit
  done
done
