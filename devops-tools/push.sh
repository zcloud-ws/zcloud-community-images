#!/usr/bin/env bash
set -e -x

_VERSION=${1}

source config.sh

if [ "x${_VERSION}" != "x" ]; then
  export IMAGE_TAG="${_VERSION}"
fi

export IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"

../scripts/push.sh

export README_BODY="{\"full_description\": \"$(cat README.md | sed -z 's/\n/\\n/g' | sed -z 's/"/\\"/g')\"}"
../scripts/update-readme.sh

