#!/usr/bin/env bash

source config.sh

export IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"

docker build -t "${IMAGE}" .