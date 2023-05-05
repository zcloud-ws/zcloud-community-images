#!/usr/bin/env bash
set -e -x

_VERSION=${1}

CONFIG_FILE="versions/${_VERSION}.sh"

if [ "x${_VERSION}" == "x" ]; then
  echo Inform the Meteor version to build.
  exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
  CONFIG_FILE="versions/default.sh"
  export IMAGE_TAG="${_VERSION}"
fi

echo "Meteor versions: ${_VERSION}"

source "${CONFIG_FILE}"

export IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"

export IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
../scripts/push.sh

export README_BODY="{\"full_description\": \"$(cat README.md | sed -z 's/\n/\\n/g')\"}"
../../scripts/update-readme.sh

