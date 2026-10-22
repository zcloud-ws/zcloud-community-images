#!/usr/bin/env bash
# Downloads and verifies an official Node.js linux-x64 binary.
# Usage: ./verify-node-release.sh <node-version> <output-dir>
# 1. Fetch SHASUMS256.txt + .sig from nodejs.org.
# 2. Verify the signature with the signer's key from nodejs/release-keys
#    (the official list of keys allowed to sign Node.js releases).
# 3. Download the tarball, check its SHA256 and extract bin/node to <output-dir>/node.
set -euo pipefail

NODE_VERSION="${1:?Inform the Node.js version, e.g. 24.22.1}"
OUT_DIR="${2:?Inform the output directory}"
NODE_VERSION="${NODE_VERSION#v}"
DIST_URL="https://nodejs.org/dist/v${NODE_VERSION}"
TARBALL="node-v${NODE_VERSION}-linux-x64.tar.xz"
RELEASE_KEYS_URL="https://raw.githubusercontent.com/nodejs/release-keys/HEAD/keys"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT
export GNUPGHOME="${WORK_DIR}/gnupg"
mkdir -m 700 "${GNUPGHOME}"

curl -fsSL "${DIST_URL}/SHASUMS256.txt" -o "${WORK_DIR}/SHASUMS256.txt"
curl -fsSL "${DIST_URL}/SHASUMS256.txt.sig" -o "${WORK_DIR}/SHASUMS256.txt.sig"

# Fingerprint of the key that signed SHASUMS256.txt.
SIGNER="$(gpg --batch --list-packets "${WORK_DIR}/SHASUMS256.txt.sig" 2>/dev/null \
  | sed -n 's/.*issuer fpr v[0-9] \([0-9A-F]\{40\}\).*/\1/p' | head -1)"
if [ -z "${SIGNER}" ]; then
  echo "Could not read the signer fingerprint from SHASUMS256.txt.sig" >&2
  exit 1
fi

# Only keys published in nodejs/release-keys are accepted.
curl -fsSL "${RELEASE_KEYS_URL}/${SIGNER}.asc" -o "${WORK_DIR}/signer.asc"
gpg --batch --quiet --import "${WORK_DIR}/signer.asc"
gpg --batch --status-fd 1 --verify "${WORK_DIR}/SHASUMS256.txt.sig" "${WORK_DIR}/SHASUMS256.txt" 2>/dev/null \
  | grep -q "^\[GNUPG:\] VALIDSIG ${SIGNER} "
echo "SHASUMS256.txt for v${NODE_VERSION} signed by ${SIGNER} (nodejs/release-keys)"

SHA256="$(awk -v f="${TARBALL}" '$2 == f { print $1 }' "${WORK_DIR}/SHASUMS256.txt")"
if [ -z "${SHA256}" ]; then
  echo "${TARBALL} not listed in SHASUMS256.txt" >&2
  exit 1
fi

curl -fsSL "${DIST_URL}/${TARBALL}" -o "${WORK_DIR}/${TARBALL}"
echo "${SHA256}  ${WORK_DIR}/${TARBALL}" | sha256sum -c -

mkdir -p "${OUT_DIR}"
tar -xJf "${WORK_DIR}/${TARBALL}" -C "${WORK_DIR}" "node-v${NODE_VERSION}-linux-x64/bin/node"
install -m 0755 "${WORK_DIR}/node-v${NODE_VERSION}-linux-x64/bin/node" "${OUT_DIR}/node"
echo "${SHA256}" > "${OUT_DIR}/node.tar.xz.sha256"
