ARG BASE_IMAGE

FROM $BASE_IMAGE

ARG PACKAGES

LABEL maintainer="zcloud.ws"

USER root

RUN curl -sS https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor | tee /etc/apt/trusted.gpg.d/google-chrome.gpg \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt update \
    && apt install -y gnupg ca-certificates google-chrome-stable $PACKAGES \
    && apt install -y fonts-ipafont-gothic \
      fonts-wqy-zenhei \
      fonts-thai-tlwg \
      fonts-kacst \
      fonts-freefont-ttf \
      libxss1 \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

USER zcloud
