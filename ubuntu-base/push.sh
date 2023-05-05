#!/usr/bin/env bash
set -e -x

source config.sh

export IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"

../scripts/push.sh

export README_BODY="{\"full_description\": \"$(cat README.md | sed -z 's/\n/\\n/g')\"}"
../scripts/update-readme.sh

