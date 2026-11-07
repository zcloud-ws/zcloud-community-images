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

# Quave One root CA

`meteor-build`, `meteor-node-runtime` and `meteor-node-mongodb-runtime` (and
their `-with-tools*` and hotfix variants) set
`NODE_EXTRA_CA_CERTS=/quave-one-tls/ca.crt`. Quave One mounts its root CA there
in every container, so Node trusts internal certificates such as managed
MongoDB, including apps with a custom Dockerfile. Tags published before
2026-11-07 do not have it; 3.5.4 was re-released with it.

# Node.js security hotfix images

When Node.js ships a security fix before Meteor, see [node-hotfix](node-hotfix/README.md) for a parallel release path that patches only the Node binary.

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
