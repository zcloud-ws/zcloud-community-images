ARG BASE_IMAGE

FROM $BASE_IMAGE

ARG PACKAGES

LABEL maintainer="zcloud.ws"

USER root

RUN apt update && apt install -y build-essential git $PACKAGES && \
        rm -rf /var/lib/apt/lists/*

USER zcloud
