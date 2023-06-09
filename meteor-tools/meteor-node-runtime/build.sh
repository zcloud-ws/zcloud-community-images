#!/usr/bin/env bash
set -e -x

METEOR_VERSION=${1}

if [ "x${METEOR_VERSION}" == "x" ]; then
  echo Inform the Meteor version to build.
  exit 1
fi

echo "Meteor versions: ${METEOR_VERSION}"

source config.sh

export IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${METEOR_VERSION}"

docker build -t "${IMAGE}" \
    --build-arg BASE_IMAGE="zcloudws/meteor-build:${METEOR_VERSION}" \
    .
