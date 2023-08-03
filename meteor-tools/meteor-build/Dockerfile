FROM zcloudws/ubuntu-base:22.04

ARG METEOR_VERSION

ARG PACKAGES

ARG INIT_COMMAND_VARS

MAINTAINER zcloud.ws

USER root

RUN apt update && apt install -y git $PACKAGES && \
        rm -rf /var/lib/apt/lists/*

USER zcloud

RUN curl https://install.meteor.com/?release=$METEOR_VERSION | sh

RUN mkdir bin && ln -s $HOME/.meteor/meteor $HOME/bin/meteor

RUN $INIT_COMMAND_VARS && $HOME/bin/meteor create pre-cache && \
    rm -rf pre-cache

