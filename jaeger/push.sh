#!/usr/bin/env bash
set -e

source config.sh

export IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
export IMAGE_LATEST="${IMAGE_REPO}/${IMAGE_NAME}:latest"
docker tag "${IMAGE}" "${IMAGE_LATEST}"

../scripts/push.sh

export IMAGE="${IMAGE_LATEST}"

../scripts/push.sh

export README_BODY="{\"full_description\": \"$(cat README.md | sed -z 's/\n/\\n/g' | sed -z 's/"/\\"/g')\"}"

../scripts/update-readme.sh
