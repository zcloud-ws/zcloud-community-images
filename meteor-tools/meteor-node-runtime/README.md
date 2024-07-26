# Nodejs runtime from Meteor

This image uses nodejs, npm and npx extracted from Meteor dev bundle.

## Running example

```bash
# Starting App with internal MongoDB
docker run --rm --name meteor-app -it \
  -v /DIR_WITH_BUNDLE_TAR:/bundle \
  --env ROOT_URL=http://localhost:3000 \
  --env PORT=3000 \
  -p 3000:3000 \
  zcloudws/meteor-node-runtime:2.11.0
```

# Npm install at startup

- To disable npm running on startup use environment variable `RUN_NPM_INSTALL=false`

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

### Tags suffix

Extra packages installed

- `${VERSION}-with-tools`: build-essential git python
- `${VERSION}-with-tools-ffmpeg`: build-essential git python ffmpeg

### User information:

- **User**: zcloud
- **Group**: zcloud
- **UID**: 65123
- **GID**: 65123


_by [Quave](https://www.quave.com.br)_
