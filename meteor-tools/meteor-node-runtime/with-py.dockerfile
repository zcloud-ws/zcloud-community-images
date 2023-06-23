ARG BASE_IMAGE

FROM $BASE_IMAGE

ARG PACKAGES

MAINTAINER zcloud.ws

USER root

RUN apt update && apt install -y $PACKAGES && \
        rm -rf /var/lib/apt/lists/*

USER zcloud
