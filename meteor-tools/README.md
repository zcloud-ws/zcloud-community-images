# Build Meteor specific version

## Using Github actions

Use meteor version from https://docs.meteor.com/changelog.html

Start GH action using Meteor version as parameter

## Using local build (use linux amd64)

```shell
cd meteor-tools
./build-all.sh 1.6.1.4
./push-all.sh 1.6.1.4
```
