#!/usr/bin/env bash
# Builds Meteor runtime hotfix images with a patched Node.js binary.
# Usage: ./build.sh <meteor-version> <node-version>
# Produces, for each published base tag that exists:
#   zcloudws/<image>:<meteor>-node<node>[-with-tools[-ffmpeg]]
# Set ALLOW_MAJOR_CHANGE=1 to allow a Node major different from the base image.
set -euo pipefail

METEOR_VERSION="${1:?Inform the Meteor version, e.g. 3.5.3}"
NODE_VERSION="${2:?Inform the Node.js version, e.g. 24.22.1}"
NODE_VERSION="${NODE_VERSION#v}"
IMAGE_REPO="${IMAGE_REPO:-zcloudws}"
IMAGES="${IMAGES:-meteor-node-runtime meteor-node-mongodb-runtime}"
VARIANTS=("" "-with-tools" "-with-tools-ffmpeg")
TAGS_FILE="${TAGS_FILE:-.hotfix-tags}"

cd "$(dirname "$0")"
./verify-node-release.sh "${NODE_VERSION}" .
: > "${TAGS_FILE}"

for IMAGE_NAME in ${IMAGES}; do
  for VARIANT in "${VARIANTS[@]}"; do
    BASE_IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${METEOR_VERSION}${VARIANT}"
    HOTFIX_IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${METEOR_VERSION}-node${NODE_VERSION}${VARIANT}"

    if ! docker pull --platform linux/amd64 "${BASE_IMAGE}"; then
      echo "Skipping ${BASE_IMAGE}: not published"
      continue
    fi

    BASE_NODE="$(docker run --rm --platform linux/amd64 --entrypoint node "${BASE_IMAGE}" -v)"
    if [ "${BASE_NODE%%.*}" != "v${NODE_VERSION%%.*}" ] && [ "${ALLOW_MAJOR_CHANGE:-0}" != "1" ]; then
      echo "Refusing ${BASE_NODE} -> v${NODE_VERSION} for ${BASE_IMAGE}: major change breaks native modules (set ALLOW_MAJOR_CHANGE=1 to force)" >&2
      exit 1
    fi
    echo "${BASE_IMAGE}: ${BASE_NODE} -> v${NODE_VERSION}"

    docker build --platform linux/amd64 -t "${HOTFIX_IMAGE}" \
      --build-arg BASE_IMAGE="${BASE_IMAGE}" \
      --build-arg NODE_VERSION="${NODE_VERSION}" \
      .
    ./smoke-test.sh "${HOTFIX_IMAGE}" "${NODE_VERSION}"
    echo "${HOTFIX_IMAGE}" >> "${TAGS_FILE}"
  done
done

rm -f node node.tar.xz.sha256
if [ ! -s "${TAGS_FILE}" ]; then
  echo "No base image found for Meteor ${METEOR_VERSION}" >&2
  exit 1
fi
echo "Built hotfix images:"
cat "${TAGS_FILE}"
