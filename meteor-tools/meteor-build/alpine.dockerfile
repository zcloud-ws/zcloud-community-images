FROM zcloudws/alpine-base:3.17

ARG METEOR_VERSION

ARG ALPINE_PACKAGES

ARG INIT_COMMAND_VARS

LABEL maintainer="zcloud.ws"

USER root

RUN apk add --no-cache $ALPINE_PACKAGES

USER zcloud


# https://github.com/meteor/meteor/archive/refs/tags/release/METEOR@1.8.1.tar.gz
RUN curl https://install.meteor.com/?release=$METEOR_VERSION | sh

RUN mkdir bin && ln -s $HOME/.meteor/meteor $HOME/bin/meteor

#RUN $INIT_COMMAND_VARS && $HOME/bin/meteor create pre-cache && \
#    rm -rf pre-cache

