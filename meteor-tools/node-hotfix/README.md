# Meteor runtime Node.js hotfix images

The regular runtime images copy Node.js from the Meteor dev_bundle, so
production runs the exact Node that Meteor tested. When Node.js ships a security
release before Meteor does, this **parallel** path publishes hotfix tags that
replace only the `node` binary with the official, verified build. Regular tags
and their workflow are unchanged. When Meteor releases with the fixed Node, go
back to the regular tags.

Tags (only for base tags that exist):

```
zcloudws/meteor-node-runtime:<meteor>-node<node>[-with-tools[-ffmpeg]]
zcloudws/meteor-node-mongodb-runtime:<meteor>-node<node>[-with-tools[-ffmpeg]]
```

Example: `zcloudws/meteor-node-mongodb-runtime:3.5.3-node24.22.1-with-tools`.

## Safety

- `SHASUMS256.txt` must have a valid GPG signature from a key published in
  [nodejs/release-keys](https://github.com/nodejs/release-keys), and the tarball
  must match its SHA256.
- Only `/opt/zcloud/nodejs/bin/node` changes. npm, MongoDB and `/scripts` come
  from the base image.
- A Node major different from the base is refused (native-module ABI), unless
  `ALLOW_MAJOR_CHANGE=1`.
- Every image is smoke-tested (version, zlib/brotli, crypto, TLS roots, npm,
  `mongod`) before it is listed for push.

## Usage

GitHub Actions: run **Meteor Runtime Node.js hotfix images** with the Meteor and
Node versions. Leave `push` off for a dry run.

Local (Docker, amd64 images):

```shell
./meteor-tools/node-hotfix/build.sh 3.5.3 24.22.1
./meteor-tools/node-hotfix/push.sh
```
