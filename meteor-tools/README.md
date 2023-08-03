# Meteor images

### [zcloudws/meteor-build](https://hub.docker.com/repository/docker/zcloudws/meteor-build/general)

Image with Meteor used for build Meteor App

Tools:
- `curl` from [zcloudws/ubuntu-base:22.04](https://hub.docker.com/repository/docker/zcloudws/ubuntu-base/general)
- `git`
- `build-essential`
- `python2 (old Meteor versions)` or `python3`

### [zcloudws/meteor-node-mongodb-runtime](https://hub.docker.com/repository/docker/zcloudws/meteor-node-mongodb-runtime/general)

Image with NodeJS and MongoDB extracted from Meteor dev bundle

Tools:
- `curl` from [zcloudws/ubuntu-base:22.04](https://hub.docker.com/repository/docker/zcloudws/ubuntu-base/general)

Tools for image tag suffix `VERSION-with-tools`:
- `curl` from [zcloudws/ubuntu-base:22.04](https://hub.docker.com/repository/docker/zcloudws/ubuntu-base/general)
- `git`
- `build-essential`
- `python2 (old Meteor versions)` or `python3`

### [zcloudws/meteor-node-runtime](https://hub.docker.com/repository/docker/zcloudws/meteor-node-runtime/general)

Image with NodeJS extracted from Meteor dev bundle

Tools:
- `curl` from [zcloudws/ubuntu-base:22.04](https://hub.docker.com/repository/docker/zcloudws/ubuntu-base/general)

Tools for image tag suffix `VERSION-with-tools`:
- `curl` from [zcloudws/ubuntu-base:22.04](https://hub.docker.com/repository/docker/zcloudws/ubuntu-base/general)
- `git`
- `build-essential`
- `python2 (old Meteor versions)` or `python3`

# Build Meteor image version

## Using GitHub actions

Use meteor version from https://docs.meteor.com/changelog.html

Start GH action using Meteor version as parameter

## Using local build (use linux amd64)

```shell
cd meteor-tools
./build-all.sh 1.6.1.4
./push-all.sh 1.6.1.4
```
