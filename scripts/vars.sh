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

if [[ -z ${DEBIAN_NAME:-} ]]; then
    echo "-> [ERROR] DEBIAN_NAME not set - aborting"
    exit 1
fi

INTERMEDIATE_REGISTRY_BASE="al3xos"
RC=""
if [[ ${CI_SERVER:-} == "yes" ]]; then
    INTERMEDIATE_REGISTRY_BASE="registry.gitlab.com/al3xos/distroless-python"
    if [[ $CI_COMMIT_BRANCH != "main" ]]; then
        RC="-rc"
    fi
elif [[ $(git name-rev --name-only HEAD) != "main" ]]; then
    RC="-rc"
fi

# use the C (glibc) distroless - required by common packages like grpcio + numpy
GOOGLE_DISTROLESS_BASE_IMAGE=gcr.io/distroless/cc-${OS_VERSION}
# Cut patch version from semver Python version for streamlined image tags: 3.12.0 -> 3.12
PYTHON_MINOR=$(echo $PYTHON_VERSION | sed -e "s#^\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\)#\1.\2#")

TEST_IMAGE_BASE=registry.gitlab.com/al3xos/distroless-python/python-distroless-tests${RC}

if [[ ${CI_SERVER:-} == "yes" ]]; then
    if [[ $CI_COMMIT_BRANCH != "main" ]]; then
        RC="-rc"
    fi
elif [[ $(git name-rev --name-only HEAD) != "main" ]]; then
    RC="-rc"
fi
PYTHON_INTERMEDIATE_BUILDER_IMAGE=${INTERMEDIATE_REGISTRY_BASE}/python-builder:${PYTHON_MINOR}-${OS_VERSION}${RC}
PYTHON_INTERMEDIATE_BUILDER_IMAGE_FULL=${INTERMEDIATE_REGISTRY_BASE}/python-builder:${PYTHON_VERSION}-${OS_VERSION}${RC}
PYTHON_INTERMEDIATE_DISTROLESS_IMAGE=${INTERMEDIATE_REGISTRY_BASE}/python-distroless:${PYTHON_MINOR}-${OS_VERSION}${RC}
PYTHON_INTERMEDIATE_DISTROLESS_IMAGE_FULL=${INTERMEDIATE_REGISTRY_BASE}/python-distroless:${PYTHON_VERSION}-${OS_VERSION}${RC}

PYTHON_FINAL_BUILDER_IMAGE=al3xos/python-builder:${PYTHON_MINOR}-${OS_VERSION}${RC}
PYTHON_FINAL_BUILDER_IMAGE_FULL=al3xos/python-builder:${PYTHON_VERSION}-${OS_VERSION}${RC}
PYTHON_FINAL_DISTROLESS_IMAGE=al3xos/python-distroless:${PYTHON_MINOR}-${OS_VERSION}${RC}
PYTHON_FINAL_DISTROLESS_IMAGE_FULL=al3xos/python-distroless:${PYTHON_VERSION}-${OS_VERSION}${RC}


if [[ $(echo "${@:-}" | grep -c -- '--debug') -gt 0 ]]; then
    PYTHON_INTERMEDIATE_DISTROLESS_IMAGE=${PYTHON_INTERMEDIATE_DISTROLESS_IMAGE}-debug
    PYTHON_INTERMEDIATE_DISTROLESS_IMAGE_FULL=${PYTHON_INTERMEDIATE_DISTROLESS_IMAGE_FULL}-debug
    PYTHON_FINAL_DISTROLESS_IMAGE=${PYTHON_FINAL_DISTROLESS_IMAGE}-debug
    PYTHON_FINAL_DISTROLESS_IMAGE_FULL=${PYTHON_FINAL_DISTROLESS_IMAGE_FULL}-debug
    TEST_IMAGE_BASE=${TEST_IMAGE_BASE}-debug
fi

if [[ -z ${CI_PIPELINE_ID:-} ]]; then
    CI_PIPELINE_ID=non-ci-$(git rev-parse --short HEAD)
fi

export PYTHON_VERSION
export PYTHON_MINOR
export OS_VERSION
export PYTHON_INTERMEDIATE_BUILDER_IMAGE
export PYTHON_INTERMEDIATE_BUILDER_IMAGE_FULL
export PYTHON_INTERMEDIATE_DISTROLESS_IMAGE
export PYTHON_INTERMEDIATE_DISTROLESS_IMAGE_FULL
export PYTHON_FINAL_BUILDER_IMAGE
export PYTHON_FINAL_BUILDER_IMAGE_FULL
export PYTHON_FINAL_DISTROLESS_IMAGE
export PYTHON_FINAL_DISTROLESS_IMAGE_FULL
export GOOGLE_DISTROLESS_BASE_IMAGE
export TEST_IMAGE_BASE
export CI_PIPELINE_ID
