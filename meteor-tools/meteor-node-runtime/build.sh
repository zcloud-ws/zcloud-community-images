#!/usr/bin/env bash
set -e -x

METEOR_VERSION=${1}

CONFIG_FILE="versions/${METEOR_VERSION}.sh"

if [ "x${METEOR_VERSION}" == "x" ]; then
  echo Inform the Meteor version to build.
  exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
  CONFIG_FILE="versions/default.sh"
  export IMAGE_TAG="${METEOR_VERSION}"
fi

if [ "x${METEOR_VERSION}" == "x" ]; then
  echo Inform the Meteor version to build.
  exit 1
fi

echo "Meteor versions: ${METEOR_VERSION}"

. "${CONFIG_FILE}"

export IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${METEOR_VERSION}"

docker build -t "${IMAGE}" \
    --build-arg BASE_IMAGE="zcloudws/meteor-build:${METEOR_VERSION}" \
    .

docker build -t "${IMAGE}-with-tools" \
    -f with-tools.dockerfile \
    --build-arg PACKAGES="${PACKAGES}" \
    --build-arg BASE_IMAGE="${IMAGE}" \
    .
