#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "-> [ERROR] This script should be sourced, not run directly"
    exit 1
fi

ARCH=""
if [[ $(uname -m) == "arm64" ]]; then
    echo "-> [WARN] Apple Silicon detected. Images will be tagged for arm64 architecture"
    ARCH="-arm64"
fi

if [[ -z ${PYTHON_VERSION:-} ]]; then
    echo "-> [ERROR] PYTHON_VERSION not set - aborting"
    exit 1
fi

if [[ -z ${OS_VERSION:-} ]]; then
    echo "-> [ERROR] OS_VERSION not set - aborting"
    exit 1
fi

# use the C (glibc) distroless - required by common packages like grpcio + numpy
GOOGLE_DISTROLESS_BASE_IMAGE=gcr.io/distroless/cc
PYTHON_BUILDER_IMAGE=mosstech/python-builder${ARCH}:${PYTHON_VERSION}-${OS_VERSION}
PYTHON_DISTROLESS_IMAGE=mosstech/python-distroless${ARCH}:${PYTHON_VERSION}-${OS_VERSION}
TEST_IMAGE_BASE=mosstech/python-distroless-tests


if [[ $(echo "${@:-}" | grep -c -- '--debug') -gt 0 ]]; then
    PYTHON_DISTROLESS_IMAGE=${PYTHON_DISTROLESS_IMAGE}-debug
    TEST_IMAGE_BASE=${TEST_IMAGE_BASE}-debug
fi

if [[ -z ${CI_PIPELINE_ID:-} ]]; then
    CI_PIPELINE_ID=non-ci-$(git rev-parse --short HEAD)
fi


export PYTHON_VERSION
export OS_VERSION
export ARCH
export PYTHON_BUILDER_IMAGE
export PYTHON_DISTROLESS_IMAGE
export GOOGLE_DISTROLESS_BASE_IMAGE
export TEST_IMAGE_BASE
export CI_PIPELINE_ID
