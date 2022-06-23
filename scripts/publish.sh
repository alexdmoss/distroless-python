#!/usr/bin/env bash

set -eouE pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")/../" >/dev/null || exit

# shellcheck disable=SC1091
. ./scripts/vars.sh

if [[ ${CI_SERVER:-} == "yes" ]]; then
    docker pull "${PYTHON_DISTROLESS_IMAGE}-intermediate-${CI_PIPELINE_ID}"
    docker pull "${PYTHON_DISTROLESS_IMAGE}-debug-intermediate-${CI_PIPELINE_ID}"
fi


docker tag "${PYTHON_DISTROLESS_IMAGE}-intermediate-${CI_PIPELINE_ID}" "${PYTHON_DISTROLESS_IMAGE}"
docker push "${PYTHON_DISTROLESS_IMAGE}"

docker tag "${PYTHON_DISTROLESS_IMAGE}-debug-intermediate-${CI_PIPELINE_ID}" "${PYTHON_DISTROLESS_IMAGE}-debug"
docker push "${PYTHON_DISTROLESS_IMAGE}-debug"

popd > /dev/null || exit
