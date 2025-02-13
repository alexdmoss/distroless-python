#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "-> [ERROR] This script should be sourced, not run directly"
    exit 1
fi

if [[ -z ${PYTHON_VERSION:-} ]]; then
    echo "-> [ERROR] PYTHON_VERSION not set - aborting"
    exit 1
fi

if [[ -z ${OS_VERSION:-} ]]; then
    echo "-> [ERROR] OS_VERSION not set - aborting"
    exit 1
fi

current_branch=$(git name-rev --name-only HEAD)
RC=""
if [[ $current_branch != "main" ]]; then
    RC="-rc-${current_branch}"
fi

# use the C (glibc) distroless - required by common packages like grpcio + numpy
GOOGLE_DISTROLESS_BASE_IMAGE=gcr.io/distroless/cc-${OS_VERSION}
# Cut patch version from semver Python version for streamlined image tags: 3.12.0 -> 3.12
PYTHON_MINOR=$(echo $PYTHON_VERSION | sed -e "s#^\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\)#\1.\2#")
PYTHON_BUILDER_IMAGE=al3xos/python-builder:${PYTHON_MINOR}-${OS_VERSION}${RC}
PYTHON_DISTROLESS_IMAGE=al3xos/python-distroless:${PYTHON_MINOR}-${OS_VERSION}${RC}
TEST_IMAGE_BASE=al3xos/python-distroless-tests${RC}


if [[ $(echo "${@:-}" | grep -c -- '--debug') -gt 0 ]]; then
    PYTHON_DISTROLESS_IMAGE=${PYTHON_DISTROLESS_IMAGE}-debug
    TEST_IMAGE_BASE=${TEST_IMAGE_BASE}-debug
fi

if [[ -z ${CI_PIPELINE_ID:-} ]]; then
    CI_PIPELINE_ID=non-ci-$(git rev-parse --short HEAD)
fi

export PYTHON_VERSION
export PYTHON_MINOR
export OS_VERSION
export PYTHON_BUILDER_IMAGE
export PYTHON_DISTROLESS_IMAGE
export GOOGLE_DISTROLESS_BASE_IMAGE
export TEST_IMAGE_BASE
export CI_PIPELINE_ID
