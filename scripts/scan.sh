#!/usr/bin/env bash
set -oeuE pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")/../" >/dev/null || exit

# shellcheck disable=SC1091
. ./scripts/vars.sh

if [[ ! $(which trivy) ]]; then
    wget https://github.com/aquasecurity/trivy/releases/download/v"${TRIVY_VERSION}"/trivy_"${TRIVY_VERSION}"_Linux-64bit.tar.gz && \
        tar zxvf trivy_"${TRIVY_VERSION}"_Linux-64bit.tar.gz && \
        mv trivy /usr/local/bin/trivy
fi

# not scanning python builder base image - should not be used outside CI
IMAGES="
${PYTHON_DISTROLESS_IMAGE}-intermediate-${CI_PIPELINE_ID}
"

for image in ${IMAGES}; do
    echo; echo "-> Trivy scan for image: ${image}"; echo
    trivy image --clear-cache
    trivy image --exit-code 1 --scanners vuln --severity CRITICAL,HIGH --no-progress "${image}"
done

popd > /dev/null || exit
