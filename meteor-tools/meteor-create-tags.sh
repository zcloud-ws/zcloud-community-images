#!/usr/bin/env sh
set -e

METEOR_VERSION="${1:-"2.12"}"
FILE_VERSION=".versions/.current-version-${METEOR_VERSION}"
NEXT_VERSION="$(../scripts/extract_next_version.sh "${FILE_VERSION}")"
SUFFIX_TAG="${METEOR_VERSION}-v${NEXT_VERSION}"
echo "${NEXT_VERSION}" > "${FILE_VERSION}"
git add "${FILE_VERSION}"
git commit -m "Create/Update meteor version. Internal version: ${NEXT_VERSION}" \
  --author="zCloud <infra@zcloud.ws>"
git tag "meteor-build-${SUFFIX_TAG}"
git tag "meteor-node-runtime-${SUFFIX_TAG}"
git tag "meteor-node-mongodb-runtime-${SUFFIX_TAG}"
git push --tags
