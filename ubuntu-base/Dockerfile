FROM ubuntu:22.04

ARG USER=zcloud

RUN apt-get update && apt-get install -y curl \
    && rm -rf /var/lib/apt/lists/*

# Create user group
RUN addgroup -gid 65123 $USER

# Create user
RUN adduser --shell /bin/bash --disabled-password -gid  65123 -u 65123 $USER

SHELL ["bash", "-l", "-c"]

USER $USER

WORKDIR /home/$USER

ENTRYPOINT ["bash", "-l"]

