#!/usr/bin/env bash

_VERSION=${1}



CONFIG_FILE="versions/${_VERSION}.sh"

if [ "x${_VERSION}" == "x" ] || [ ! -f "$CONFIG_FILE" ]; then
  echo Inform the Meteor version to build.
  exit 1
fi

echo "Meteor versions: ${_VERSION}"

source "${CONFIG_FILE}"

export IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"

docker build -t "${IMAGE}" . \
  --build-arg METEOR_VERSION="${METEOR_VERSION}" \
  --build-arg PACKAGES="${PACKAGES}" \
  --build-arg INIT_COMMAND_VARS="${INIT_COMMAND_VARS}"
