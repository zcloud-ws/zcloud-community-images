# Meteor for build apps inside container 

## Usage example

```dockerignore
# Ignoring unnecessary files to optimize the build
.git/
.meteor/local/
node_modules/
```

## Dockerfile to build app and create image with NodeJS runtime

```dockerfile
FROM zcloudws/meteor-meteor:2.11.0 as builder

ADD 

```

# Meteor UP

This image is compatible with [Meteor UP](https://meteor-up.com/).

```javascript
// Usage example
{
// ...
    docker: {
        image: 'zcloudws/meteor-node-runtime:METEOR_VERSION'
    // ...
    }
// ...
};
```

### User information:

- **User**: zcloud
- **Group**: zcloud
- **UID**: 65123
- **GID**: 65123


_by [Quave](https://www.quave.com.br)_
