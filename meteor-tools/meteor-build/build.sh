#!/usr/bin/env bash
set -e

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

. "${CONFIG_FILE}"

export IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"

docker build -t "${IMAGE}" . \
  --build-arg METEOR_VERSION="${_VERSION}" \
  --build-arg PACKAGES="${PACKAGES}" \
  --build-arg INIT_COMMAND_VARS="${INIT_COMMAND_VARS}" \
  --build-arg METEOR_BOOTSTRAP_VERSION="${METEOR_BOOTSTRAP_VERSION:-${_VERSION}}" \
  --build-arg METEOR_TOOL_VERSION="${METEOR_TOOL_VERSION:-}" \
  --build-arg PRE_CACHE_COMMAND="${PRE_CACHE_COMMAND:-/home/zcloud/bin/meteor create pre-cache && rm -rf pre-cache}"
