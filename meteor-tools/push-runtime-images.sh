#!/usr/bin/env bash
set -e
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
    echo "Pushing ${DIR}..."
    cd "${DIR}"
    ./push.sh "${METEOR_VERSION}"
    cd "${BASE_DIR}"
    echo "Pushed ${DIR}"
  done

done
