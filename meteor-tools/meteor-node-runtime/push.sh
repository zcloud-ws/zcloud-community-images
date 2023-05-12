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

../../scripts/push.sh

export README_BODY="{\"full_description\": \"$(cat README.md | sed -z 's/\n/\\n/g' | sed -z 's/"/\\"/g')\"}"
../../scripts/update-readme.sh
