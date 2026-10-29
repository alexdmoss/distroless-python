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
    EXTRA_TAGS=(-t "${PYTHON_BUILDER_IMAGE_FULL}-${IMMUTABLE_TAG_SUFFIX}")
else
    PYTHON_BUILDER_IMAGE="${PYTHON_INTERMEDIATE_BUILDER_IMAGE}"
    PYTHON_BUILDER_IMAGE_FULL="${PYTHON_INTERMEDIATE_BUILDER_IMAGE_FULL}"
    TAG="-${CI_PIPELINE_ID}-intermediate"
    EXTRA_TAGS=()
fi

docker pull "${PYTHON_BUILDER_IMAGE}" || true

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --build-arg PYTHON_BASE_IMAGE="${PYTHON_BASE_IMAGE}" \
    -t "${PYTHON_BUILDER_IMAGE}${TAG}" \
    -t "${PYTHON_BUILDER_IMAGE_FULL}${TAG}" \
    "${EXTRA_TAGS[@]}" \
    -f builder.Dockerfile . \
    --push

popd > /dev/null || exit
