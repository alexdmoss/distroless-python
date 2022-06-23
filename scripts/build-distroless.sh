#!/usr/bin/env bash

set -eouE pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")/../" >/dev/null || exit

# shellcheck disable=SC1091
. ./scripts/vars.sh

if [[ ${ARCH} == "-arm64" ]]; then
    CHIPSET_ARCH=aarch64-linux-gnu
else
    CHIPSET_ARCH=x86_64-linux-gnu
fi

docker build \
    --build-arg PYTHON_BUILDER_IMAGE="${PYTHON_BUILDER_IMAGE}" \
    --build-arg GOOGLE_DISTROLESS_BASE_IMAGE="${GOOGLE_DISTROLESS_BASE_IMAGE}" \
    --build-arg CHIPSET_ARCH="${CHIPSET_ARCH}" \
    -t "${PYTHON_DISTROLESS_IMAGE}-intermediate-${CI_PIPELINE_ID}" \
    -f distroless.Dockerfile .


docker build \
    --build-arg PYTHON_BUILDER_IMAGE="${PYTHON_BUILDER_IMAGE}" \
    --build-arg GOOGLE_DISTROLESS_BASE_IMAGE="${GOOGLE_DISTROLESS_BASE_IMAGE}:debug" \
    --build-arg CHIPSET_ARCH="${CHIPSET_ARCH}" \
    -t "${PYTHON_DISTROLESS_IMAGE}-debug-intermediate-${CI_PIPELINE_ID}" \
    -f distroless.Dockerfile .

if [[ ${CI_SERVER:-} == "yes" ]]; then
    docker push "${PYTHON_DISTROLESS_IMAGE}-intermediate-${CI_PIPELINE_ID}"
    docker push "${PYTHON_DISTROLESS_IMAGE}-debug-intermediate-${CI_PIPELINE_ID}"
fi

popd > /dev/null || exit
