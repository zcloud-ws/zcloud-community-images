FROM zcloudws/ubuntu-base:22.04

ARG METEOR_VERSION

ARG PACKAGES

ARG INIT_COMMAND_VARS

LABEL maintainer="zcloud.ws"

USER root

RUN apt update && apt install -y git $PACKAGES && \
        rm -rf /var/lib/apt/lists/*

COPY files/zcloud-profile.sh /etc/profile.d/zcloud-profile.sh

RUN chmod +x /etc/profile.d/zcloud-profile.sh

USER zcloud

RUN curl https://install.meteor.com/?release=$METEOR_VERSION | sh

RUN mkdir bin && ln -s $HOME/.meteor/meteor $HOME/bin/meteor

RUN ln -s $HOME/.meteor/packages/meteor-tool/*.*.*/mt-os.linux.x86_64/dev_bundle/bin/* $HOME/bin/

RUN $INIT_COMMAND_VARS && $HOME/bin/meteor create pre-cache && \
    rm -rf pre-cache

