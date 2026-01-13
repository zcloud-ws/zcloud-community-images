#!/usr/bin/env bash
set -e -x

_VERSION=${1}

source config.sh

if [ "x${_VERSION}" != "x" ]; then
  export OTEL_VERSION="${_VERSION}"
fi

export IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${OTEL_VERSION}"

docker build --build-arg OTEL_VERSION="${OTEL_VERSION}" -t "${IMAGE}" .
