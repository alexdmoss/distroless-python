#!/usr/bin/env bash
set -eouE pipefail

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "-> [ERROR] This script should be sourced, not run directly"
    exit 1
fi

function test_kubernetes_image() {

    local image_tag=$1
    local assertion=$2

    if [[ ${CI_SERVER:-} == "yes" ]]; then
        echo "${DOCKER_CREDS}" | docker login --username al3xos --password-stdin
        _console_msg "Installing Kind ..." INFO
        curl -sLo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
        chmod +x ./kind
        mv ./kind /usr/local/bin/kind
    fi

    export IMAGE_TAG="${image_tag}"
    docker push "${IMAGE_TAG}"

    # using kind helps us minimise our dependencies on another cluster existing somewhere
    _console_msg "Creating Kind cluster ..." INFO

    CLUSTER=distroless-test-"${CI_PIPELINE_ID}"

    kind create cluster --name="${CLUSTER}" --config=./tests/kubernetes/kind.yaml --wait=60s

    _console_msg "Configure kubectl context when using kind inside gitlab-ci dind ..." INFO

    if [[ ${CI_SERVER:-} == "yes" ]]; then
        kubectl config set-cluster kind-"${CLUSTER}" --server=https://docker:6443 --insecure-skip-tls-verify=true
        kubectl config use-context kind-"${CLUSTER}"
    fi
    kubectl cluster-info

    # believe it or not this seems easier than getting .kube/config to work inside distroless ...
    envsubst "\$IMAGE_TAG \$PYTHON_MINOR \$OS_VERSION" < ./tests/kubernetes/k8s.yaml | kubectl apply  -n=default -f -

    kubectl rollout status deploy/distroless-python-test-"${PYTHON_MINOR}"-"${OS_VERSION}" -n=default --timeout=180s
    
    kubectl get pods -n=default
    kubectl describe pods -l=app=distroless-python-test-"${PYTHON_MINOR}"-"${OS_VERSION}" -n=default
    kubectl top pods -A
    kubectl top nodes -A
    sleep 10

    output=$(kubectl logs -l=app=distroless-python-test-"${PYTHON_MINOR}"-"${OS_VERSION}" -n=default)

    if [[ $(echo "${output}" | grep -c "${assertion}") -eq 0 ]]; then
        _console_msg "Test failed: [${output}] did not contain [${assertion}]" ERROR
        failures=$((failures + 1))
    else
        _console_msg "Test passed: Output [${output}]" INFO
    fi

    kind delete cluster --name="${CLUSTER}"
    
}
