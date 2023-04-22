#!/usr/bin/env bash
set -e

source config.sh

export IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"

#docker push "${IMAGE}"

export README_BODY="{\"full_description\": \"$(cat README.md | sed -z 's/\n/\\n/g')\"}"

../scripts/push.sh
