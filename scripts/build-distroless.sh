#!/usr/bin/env bash

set -eouE pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")/../" >/dev/null || exit

# shellcheck disable=SC1091
. ./scripts/vars.sh

docker buildx create --name multiarch-builder --use --bootstrap --driver docker-container --platform linux/amd64,linux/arm64 || true

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --build-arg PYTHON_BUILDER_IMAGE="${PYTHON_BUILDER_IMAGE}" \
    --build-arg GOOGLE_DISTROLESS_BASE_IMAGE="${GOOGLE_DISTROLESS_BASE_IMAGE}" \
    -t "${PYTHON_DISTROLESS_IMAGE}-intermediate-${CI_PIPELINE_ID}" \
    -f distroless.Dockerfile .


docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --build-arg PYTHON_BUILDER_IMAGE="${PYTHON_BUILDER_IMAGE}" \
    --build-arg GOOGLE_DISTROLESS_BASE_IMAGE="${GOOGLE_DISTROLESS_BASE_IMAGE}:debug" \
    -t "${PYTHON_DISTROLESS_IMAGE}-debug-intermediate-${CI_PIPELINE_ID}" \
    -f distroless.Dockerfile .

if [[ ${CI_SERVER:-} == "yes" ]]; then
    docker buildx push "${PYTHON_DISTROLESS_IMAGE}-intermediate-${CI_PIPELINE_ID}"
    docker buildx push "${PYTHON_DISTROLESS_IMAGE}-debug-intermediate-${CI_PIPELINE_ID}"
fi

popd > /dev/null || exit
