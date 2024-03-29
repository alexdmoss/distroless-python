#!/usr/bin/env bash
set -eouE pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")/../" >/dev/null || exit

# shellcheck disable=SC1091
. ./scripts/vars.sh


docker pull "${PYTHON_BUILDER_IMAGE}" || true

docker build \
    --build-arg PYTHON_VERSION="${PYTHON_VERSION}" \
    --build-arg DEBIAN_NAME="${DEBIAN_NAME}" \
    -t "${PYTHON_BUILDER_IMAGE}" \
    -f builder.Dockerfile .

if [[ ${CI_SERVER:-} == "yes" ]]; then
    docker push "${PYTHON_BUILDER_IMAGE}"
fi

popd > /dev/null || exit
