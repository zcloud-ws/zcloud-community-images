#!/usr/bin/env bash
set -e -x

_VERSION=${1}

source config.sh

if [ "x${_VERSION}" != "x" ]; then
  export IMAGE_TAG="${_VERSION}"
fi

export IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"

docker build -t "${IMAGE}" \
    .
