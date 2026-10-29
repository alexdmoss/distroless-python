#!/usr/bin/env bash

set -eouE pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")/../" >/dev/null || exit

# shellcheck disable=SC1091
. ./scripts/vars.sh


if [[ "${1:-}" == "--publish" ]]; then
    TAG=""
    PYTHON_BUILDER_IMAGE="${PYTHON_FINAL_BUILDER_IMAGE}"
    PYTHON_DISTROLESS_IMAGE="${PYTHON_FINAL_DISTROLESS_IMAGE}"
    PYTHON_DISTROLESS_IMAGE_FULL="${PYTHON_FINAL_DISTROLESS_IMAGE_FULL}"
    EXTRA_TAGS=(-t "${PYTHON_DISTROLESS_IMAGE_FULL}-${IMMUTABLE_TAG_SUFFIX}")
    EXTRA_DEBUG_TAGS=(-t "${PYTHON_DISTROLESS_IMAGE_FULL}-debug-${IMMUTABLE_TAG_SUFFIX}")
else
    TAG="-${CI_PIPELINE_ID}-intermediate"
    PYTHON_BUILDER_IMAGE="${PYTHON_INTERMEDIATE_BUILDER_IMAGE}${TAG}"
    PYTHON_DISTROLESS_IMAGE="${PYTHON_INTERMEDIATE_DISTROLESS_IMAGE}"
    PYTHON_DISTROLESS_IMAGE_FULL="${PYTHON_INTERMEDIATE_DISTROLESS_IMAGE_FULL}"
    EXTRA_TAGS=()
    EXTRA_DEBUG_TAGS=()
fi

docker buildx create --name multiarch-builder --use --bootstrap --driver docker-container --platform linux/amd64,linux/arm64 || true

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --build-arg PYTHON_BUILDER_IMAGE="${PYTHON_BUILDER_IMAGE}" \
    --build-arg GOOGLE_DISTROLESS_BASE_IMAGE="${GOOGLE_DISTROLESS_BASE_IMAGE}" \
    --build-arg PYTHON_MINOR="${PYTHON_MINOR}" \
    --build-arg PYTHON_VERSION="${PYTHON_VERSION}" \
    -t "${PYTHON_DISTROLESS_IMAGE}${TAG}" \
    -t "${PYTHON_DISTROLESS_IMAGE_FULL}${TAG}" \
    "${EXTRA_TAGS[@]}" \
    -f distroless.Dockerfile . \
    --push

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --build-arg PYTHON_BUILDER_IMAGE="${PYTHON_BUILDER_IMAGE}" \
    --build-arg GOOGLE_DISTROLESS_BASE_IMAGE="${GOOGLE_DISTROLESS_DEBUG_BASE_IMAGE}" \
    --build-arg PYTHON_MINOR="${PYTHON_MINOR}" \
    --build-arg PYTHON_VERSION="${PYTHON_VERSION}" \
    -t "${PYTHON_DISTROLESS_IMAGE}-debug${TAG}" \
    -t "${PYTHON_DISTROLESS_IMAGE_FULL}-debug${TAG}" \
    "${EXTRA_DEBUG_TAGS[@]}" \
    -f distroless.Dockerfile . \
    --push

print_image_versions "${PYTHON_DISTROLESS_IMAGE}${TAG}"

popd > /dev/null || exit
