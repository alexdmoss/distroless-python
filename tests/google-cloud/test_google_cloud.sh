#!/usr/bin/env bash
set -ouE pipefail

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "-> [ERROR] This script should be sourced, not run directly"
    exit 1
fi


function test_google_cloud_image() {
    local image_tag=$1
    local assertion=$2

    _console_msg "Creating docker network ..." INFO

    docker network create distroless || true

    _console_msg "Starting PubSub Emulator ..." INFO

    docker run --rm --name=pubsub-emulator --network=distroless -d --expose 8085 -p 8085:8085 mosstech/pubsub-emulator:latest
    
    _console_msg "Testing image output for [${image_tag}]" INFO

    output=$(docker run --rm -e=PUBSUB_EMULATOR_HOST=pubsub-emulator:8085 --network=distroless "${image_tag}")

    docker rm -f pubsub-emulator >/dev/null 2>&1 || true

    if [[ $(echo "${output}" | grep -c "${assertion}") -eq 0 ]]; then
        _console_msg "Test failed: [${output}] did not contain [${assertion}]" ERROR
        failures=$((failures + 1))
    else
        _console_msg "Test passed: Output [${output}]" INFO
    fi
}
