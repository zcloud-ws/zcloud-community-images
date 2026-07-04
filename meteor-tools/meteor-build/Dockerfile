FROM zcloudws/ubuntu-base:22.04

ARG METEOR_VERSION

ARG METEOR_BOOTSTRAP_VERSION

ARG METEOR_TOOL_VERSION

ARG PACKAGES

ARG INIT_COMMAND_VARS

ARG PRE_CACHE_COMMAND

LABEL maintainer="zcloud.ws"

USER root

RUN apt update && apt install -y git $PACKAGES && \
        rm -rf /var/lib/apt/lists/*

COPY files/zcloud-profile.sh /etc/profile.d/zcloud-profile.sh

RUN chmod +x /etc/profile.d/zcloud-profile.sh

USER zcloud

RUN set -eux; \
    curl -fsSL "https://install.meteor.com/?release=${METEOR_BOOTSTRAP_VERSION:-$METEOR_VERSION}" | sh; \
    if [ "${METEOR_BOOTSTRAP_VERSION:-$METEOR_VERSION}" != "$METEOR_VERSION" ]; then \
        "$HOME/.meteor/meteor" --release "$METEOR_VERSION" --version; \
        TOOL_VERSION="${METEOR_TOOL_VERSION:-$METEOR_VERSION}"; \
        if [ ! -d "$HOME/.meteor/packages/meteor-tool/${TOOL_VERSION}/mt-os.linux.x86_64" ] && \
           [ -d "$HOME/.meteor/packages/meteor-tool/${TOOL_VERSION}.0/mt-os.linux.x86_64" ]; then \
            TOOL_VERSION="${TOOL_VERSION}.0"; \
        fi; \
        test -d "$HOME/.meteor/packages/meteor-tool/${TOOL_VERSION}/mt-os.linux.x86_64"; \
        BOOTSTRAP_TOOL_LINK="$HOME/.meteor/packages/meteor-tool/${METEOR_BOOTSTRAP_VERSION}"; \
        BOOTSTRAP_TOOL_DIR="$(readlink "$BOOTSTRAP_TOOL_LINK" || true)"; \
        ln -snf "packages/meteor-tool/${TOOL_VERSION}/mt-os.linux.x86_64/meteor" "$HOME/.meteor/meteor"; \
        rm -rf "$BOOTSTRAP_TOOL_LINK"; \
        if [ -n "$BOOTSTRAP_TOOL_DIR" ]; then \
            rm -rf "$HOME/.meteor/packages/meteor-tool/${BOOTSTRAP_TOOL_DIR}"; \
        fi; \
    fi

RUN mkdir bin && \
    printf '%s\n' \
        '#!/usr/bin/env bash' \
        'export METEOR_SPRINGBOARD_RELEASE="${METEOR_SPRINGBOARD_RELEASE:-'"$METEOR_VERSION"'}"' \
        'exec "$HOME/.meteor/meteor" "$@"' \
        > "$HOME/bin/meteor" && \
    chmod +x "$HOME/bin/meteor"

RUN set -eux; \
    METEOR_TOOL_DIR="$(dirname "$(readlink "$HOME/.meteor/meteor")")"; \
    ln -s "$HOME/.meteor/${METEOR_TOOL_DIR}/dev_bundle/bin/"* "$HOME/bin/"

RUN $INIT_COMMAND_VARS && bash -lc "$PRE_CACHE_COMMAND"

