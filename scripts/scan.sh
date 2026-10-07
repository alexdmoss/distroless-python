#!/usr/bin/env bash
set -oeuE pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")/../" >/dev/null || exit

# shellcheck disable=SC1091
. ./scripts/vars.sh

# ci-tools image ships its own trivy, so install the pinned version if it doesn't match
INSTALLED_TRIVY_VERSION=$(trivy --version 2>/dev/null | sed -n 's/^Version: //p' || true)
if [[ "${INSTALLED_TRIVY_VERSION}" != "${TRIVY_VERSION}" ]]; then
    echo "-> Installing trivy ${TRIVY_VERSION} (found: ${INSTALLED_TRIVY_VERSION:-none})"
    wget -q https://github.com/aquasecurity/trivy/releases/download/v"${TRIVY_VERSION}"/trivy_"${TRIVY_VERSION}"_Linux-64bit.tar.gz && \
        tar zxf trivy_"${TRIVY_VERSION}"_Linux-64bit.tar.gz trivy && \
        mv trivy /usr/local/bin/trivy && \
        rm trivy_"${TRIVY_VERSION}"_Linux-64bit.tar.gz
    hash -r
fi
echo "-> Trivy version: $(trivy --version | sed -n 's/^Version: //p')"

# not scanning python builder base image - should not be used outside CI
IMAGES="
${PYTHON_INTERMEDIATE_DISTROLESS_IMAGE}-${CI_PIPELINE_ID}-intermediate
"

for image in ${IMAGES}; do
    echo; print_image_versions "${image}"
    echo; echo "-> Trivy scan for image: ${image}"; echo
    trivy clean --scan-cache
    trivy image --exit-code 1 --scanners vuln --severity CRITICAL,HIGH --no-progress "${image}"
done

popd > /dev/null || exit
