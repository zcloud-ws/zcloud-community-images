#!/usr/bin/env bash
set -e

METEOR_VERSION=${1}

if [ "x${METEOR_VERSION}" == "x" ]; then
  echo Inform the Meteor version to build.
  exit 1
fi

echo "Meteor versions: ${METEOR_VERSION}"

CONFIG_FILE="versions/${METEOR_VERSION}.sh"

if [ "x${METEOR_VERSION}" == "x" ]; then
  echo Inform the Meteor version to build.
  exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
  CONFIG_FILE="versions/default.sh"
  export IMAGE_TAG="${METEOR_VERSION}"
fi

. "${CONFIG_FILE}"

export IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${METEOR_VERSION}"

../../scripts/push.sh

export README_BODY="{\"full_description\": \"$(cat README.md | sed -z 's/\n/\\n/g' | sed -z 's/"/\\"/g')\"}"
../../scripts/update-readme.sh

export IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${METEOR_VERSION}-with-py"

../../scripts/push.sh
