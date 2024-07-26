#!/usr/bin/env bash
set -e -x

VERSIONS=${*}
DIRS="meteor-node-runtime meteor-node-mongodb-runtime"

for METEOR_VERSION in ${VERSIONS}; do

  if [ "x${METEOR_VERSION}" == "x" ]; then
    echo Inform the Meteor version to build.
    exit 1
  fi

  echo "Meteor versions: ${METEOR_VERSION}"

  BASE_DIR=$PWD

  for DIR in $DIRS; do
    cd "${DIR}" || exit
    ./build.sh "${METEOR_VERSION}"
    cd "${BASE_DIR}" || exit
  done
done
