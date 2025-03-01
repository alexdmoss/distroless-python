#!/usr/bin/env bash
set -eouE pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")/../" >/dev/null || exit

# shellcheck disable=SC1091
. ./scripts/vars.sh

docker buildx create --name multiarch-builder --use --bootstrap --driver docker-container --platform linux/amd64,linux/arm64 || true

if [[ "${1:-}" == "--publish" ]]; then
    PYTHON_BUILDER_IMAGE="${PYTHON_FINAL_BUILDER_IMAGE}"
    PYTHON_BUILDER_IMAGE_FULL="${PYTHON_FINAL_BUILDER_IMAGE_FULL}"
    TAG=""
else
    PYTHON_BUILDER_IMAGE="${PYTHON_INTERMEDIATE_BUILDER_IMAGE}"
    PYTHON_BUILDER_IMAGE_FULL="${PYTHON_INTERMEDIATE_BUILDER_IMAGE_FULL}"
    TAG="-${CI_PIPELINE_ID}-intermediate"
fi

docker pull "${PYTHON_BUILDER_IMAGE}" || true

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --build-arg PYTHON_VERSION="${PYTHON_VERSION}" \
    --build-arg DEBIAN_NAME="${DEBIAN_NAME}" \
    -t "${PYTHON_BUILDER_IMAGE}${TAG}" \
    -t "${PYTHON_BUILDER_IMAGE_FULL}${TAG}" \
    -f builder.Dockerfile . \
    --push

popd > /dev/null || exit
