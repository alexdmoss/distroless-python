#!/usr/bin/env bash
set -eouE pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")/../" >/dev/null || exit

# shellcheck disable=SC1091
. ./scripts/vars.sh

docker buildx create --name multiarch-builder --use --bootstrap --driver docker-container --platform linux/amd64,linux/arm64 || true

docker pull "${PYTHON_BUILDER_IMAGE}" || true

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --build-arg PYTHON_VERSION="${PYTHON_VERSION}" \
    --build-arg DEBIAN_NAME="${DEBIAN_NAME}" \
    -t "${PYTHON_BUILDER_IMAGE}" \
    -f builder.Dockerfile . \
    --push

popd > /dev/null || exit
