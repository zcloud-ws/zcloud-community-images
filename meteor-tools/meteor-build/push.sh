#!/usr/bin/env bash
set -e -x

_VERSION=${1}

CONFIG_FILE="versions/${_VERSION}.sh"

if [ "x${_VERSION}" == "x" ] || [ ! -f "$CONFIG_FILE" ]; then
  echo Inform the Meteor version to push.
  exit 1
fi

echo "Meteor versions: ${_VERSION}"

source "${CONFIG_FILE}"

export IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"

../../scripts/push.sh
