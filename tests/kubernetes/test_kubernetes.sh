#!/usr/bin/env bash
set -ouE pipefail

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "-> [ERROR] This script should be sourced, not run directly"
    exit 1
fi

function test_kubernetes_image() {

    local image_tag=$1
    local assertion=$2

    if [[ ${CI_SERVER:-} == "yes" ]]; then
        _console_msg "Installing Kind ..." INFO
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64
        chmod +x ./kind
        mv ./kind /usr/local/kind
    fi

    # using kind helps us minimise our dependencies on another cluster existing somewhere
    _console_msg "Creating Kind cluster ..." INFO

    CLUSTER=distroless-test-$(( RANDOM%100000 ))

    kind create cluster --name="${CLUSTER}" --wait=60s

    # believe it or not this seems easier than getting .kube/config to work inside distroless ...
    pushd "$(dirname "${BASH_SOURCE[0]}")/" >/dev/null || exit

    if [[ ${CI_SERVER:-} == "yes" ]]; then
        docker push "${image_tag}"
    fi
    
    export IMAGE_TAG="${image_tag}"
    envsubst "\$IMAGE_TAG \$PYTHON_VERSION \$OS_VERSION" < k8s.yaml | kubectl apply -n=default -f -
    kubectl rollout status deploy/distroless-python-test-"${PYTHON_VERSION}"-"${OS_VERSION}" -n=default --timeout=120s
    popd >/dev/null || exit
    
    sleep 10

    output=$(kubectl logs -l=app=distroless-python-test-"${PYTHON_VERSION}"-"${OS_VERSION}" -n=default)

    if [[ $(echo "${output}" | grep -c "${assertion}") -eq 0 ]]; then
        _console_msg "Test failed: [${output}] did not contain [${assertion}]" ERROR
        failures=$((failures + 1))
    else
        _console_msg "Test passed: Output [${output}]" INFO
    fi

    kind delete cluster --name="${CLUSTER}"
    
}
