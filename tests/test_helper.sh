#!/usr/bin/env bash
set -ouE pipefail

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "-> [ERROR] This script should be sourced, not run directly"
    exit 1
fi


function build_test_image() {
    local image_tag=$1
    local test_name=$2

    _console_msg "Building test image [${test_name}]" INFO

    pushd "$(dirname "${BASH_SOURCE[0]}")/${test_name}" >/dev/null || exit

    docker build \
        --build-arg PYTHON_VERSION="${PYTHON_VERSION}" \
        --build-arg DEBIAN_NAME="${DEBIAN_NAME}" \
        --build-arg PYTHON_BUILDER_IMAGE="${PYTHON_INTERMEDIATE_BUILDER_IMAGE}-${CI_PIPELINE_ID}-intermediate" \
        --build-arg PYTHON_DISTROLESS_IMAGE="${PYTHON_INTERMEDIATE_DISTROLESS_IMAGE}-${CI_PIPELINE_ID}-intermediate" \
        -t "${image_tag}" .

    if [[ "${?}" -gt 0 ]]; then
        _console_msg "Build FAILED" ERROR
        failures=$((failures + 1))
    fi

    popd >/dev/null || exit

}


function test_docker_output() {
    local image_tag=$1
    local assertion=$2
    local args=${3:-}

    _console_msg "Testing image output for [${image_tag}]" INFO

    if [[ -z ${args} ]]; then
        output=$(docker run --rm "${image_tag}")
    else
        output=$(docker run --rm "${image_tag}" "${args}")
    fi

    if [[ $(echo "${output}" | grep -c "${assertion}") -eq 0 ]]; then
        _console_msg "Test failed: [$assertion] not found in output [$output]" ERROR
        failures=$((failures + 1))
    else
        _console_msg "Test passed: Output [${output}]" INFO
    fi
}


function test_docker_http() {
    local image_tag=$1
    local assertion=$2

    _console_msg "Testing http output for [${image_tag}]" INFO

    if [[ ${CI_SERVER:-} == "yes" ]]; then
        export HOSTNAME=docker
    else
        export HOSTNAME=localhost
    fi

    docker rm -f distroless-test >/dev/null 2>&1 || true
    docker run --rm --detach --name=distroless-test -p 5000:5000 "${image_tag}"
    sleep 5     # CI needs a bit of time ... yawn

    echo "---------------------- STARTUP LOGS ----------------------"
    if [[ $(docker ps | grep -c distroless-test) -gt 0 ]]; then
        docker logs distroless-test
    else
        docker run --rm --name=distroless-test -p 5000:5000 "${image_tag}"
    fi
    echo "---------------------- STARTUP LOGS ----------------------"

    output=$(curl -iks http://${HOSTNAME}:5000/)

    if [[ $(echo "${output}" | grep -c "${assertion}") -eq 0 ]]; then
        _console_msg "Test failed: [$assertion] not found in output [$output]" ERROR
        failures=$((failures + 1))
    fi

    if [[ $(echo "${output}" | grep -c "200 OK") -eq 0 ]]; then
        _console_msg "Test failed: HTTP 200 return code not received" ERROR
        failures=$((failures + 1))
    fi

    _console_msg "Test passed: ${output}" INFO

    docker rm -f distroless-test >/dev/null 2>&1 || true

}


function _console_msg() {

    local msg=${1}
    local level=${2:-}
    local ts=${3:-}

    if [[ -z ${level} ]]; then level=INFO; fi
    if [[ -n ${ts} ]]; then ts=" [$(date +"%Y-%m-%d %H:%M")]"; fi

    echo ""

    if [[ ${level} == "ERROR" ]] || [[ ${level} == "CRIT" ]] || [[ ${level} == "FATAL" ]]; then
        (echo 2>&1)
        (echo >&2 "-> [${level}]${ts} ${msg}")
    else
        (echo "-> [${level}]${ts} ${msg}")
    fi

    echo ""

}
