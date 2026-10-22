#!/usr/bin/env bash
# Usage: ./smoke-test.sh <image> <node-version>
set -euo pipefail

IMAGE="${1:?Inform the image}"
NODE_VERSION="${2:?Inform the Node.js version}"

docker run --rm --platform linux/amd64 --entrypoint bash -e NODE_VERSION="${NODE_VERSION}" "${IMAGE}" -c '
set -euo pipefail
test "$(whoami)" = "zcloud"
node -e "
const assert = require(\"assert\");
assert.strictEqual(process.version, \"v\" + process.env.NODE_VERSION);
const zlib = require(\"zlib\");
const data = Buffer.from(\"zcloud\".repeat(1000));
assert.ok(zlib.brotliDecompressSync(zlib.brotliCompressSync(data)).equals(data));
assert.ok(zlib.gunzipSync(zlib.gzipSync(data)).equals(data));
assert.ok(require(\"crypto\").randomUUID());
assert.ok(require(\"tls\").rootCertificates.length > 0);
console.log(process.version, \"openssl\", process.versions.openssl, \"abi\", process.versions.modules);
"
echo "npm $(npm -v)"
if command -v mongod >/dev/null; then mongod --version | head -1; fi
'
