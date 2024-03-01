FROM zcloudws/ubuntu-base:22.04

USER root

RUN apt-get update && apt-get install -y dnsutils iputils-ping iputils-tracepath mtr nmap git wget \
    && rm -rf /var/lib/apt/lists/*

USER zcloud
