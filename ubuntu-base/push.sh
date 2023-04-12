#!/usr/bin/env bash
set -e -x

source config.sh

export IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"

../scripts/push.sh
