#!/usr/bin/env bash
set -e

source releases.sh

for METEOR_VERSION in ${RELEASES}; do
  IMAGE_VERSION="$(docker run --rm -it --entrypoint /home/zcloud/bin/meteor zcloudws/meteor-build:${METEOR_VERSION} --version | sed 's/[^0-9.]//g')"
  echo "Meteor version ${METEOR_VERSION} / Image version: ${IMAGE_VERSION}"
  if [  "${IMAGE_VERSION}" != "${METEOR_VERSION}" ]; then
    exit 1
  fi
done
