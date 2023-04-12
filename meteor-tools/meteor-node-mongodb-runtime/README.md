# Nodejs runtime from Meteor with MongoDB 

This image uses nodejs, npm, npx and mongod extracted from Meteor dev bundle.

## Running example

```bash
# Starting App with internal MongoDB
docker run --rm --name meteor-app -it \
  -v /DIR_WITH_BUNDLE_TAR:/bundle \
  -v /DIR_MONGO_DATA_WITH_WRITE_PERMISSION:/mongodb-data \
  --env USE_INTERNAL_MONGODB=true \
  --env ROOT_URL=http://localhost:3000 \
  --env PORT=3000 \
  -p 3000:3000 \
  -p 27018:27017 \
  zcloudws/meteor-node-mongodb-runtime:2.11.0
```

# MongoDB

- Internal MongoDB run on port 27017
- To start internal MongoDB use environment variable `USE_INTERNAL_MONGODB=true`
- To change default data directory use environment variable `MONGODB_DATA_DIR=/mongodb-data`
- To pass extra arguments for `mongod` use environment variable `MONGODB_EXTRA_ARGS`

### User information:

- **User**: zcloud
- **Group**: zcloud
- **UID**: 65123
- **GID**: 65123


_by [Quave](https://www.quave.com.br)_
