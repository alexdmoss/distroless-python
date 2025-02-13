#!/usr/bin/env bash
# shellcheck disable=SC1091
set -ouE pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")/../" >/dev/null || exit

. ./scripts/vars.sh "${@:-}"
. ./tests/test_helper.sh

failures=0
test_run=0

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -t|--target) target="$2"; shift ;;
        -d|--debug) debug=1; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [[ -z ${target:-} ]]; then
    target=ALL
fi

if [[ ${debug:-} == 1 ]]; then
    _console_msg "Running tests against the DEBUG images" INFO
fi

# ----------------------------------------------------------

if [[ ${target} == "version" ]] || [[ ${target} == "ALL" ]]; then
    test_run=1
    test_docker_output "${PYTHON_DISTROLESS_IMAGE}-${CI_PIPELINE_ID}-intermediate" "Python ${PYTHON_VERSION}" "--version"
fi

if [[ ${target} == "hello-world" ]] || [[ ${target} == "ALL" ]]; then
    test_run=1
    IMAGE_NAME="${TEST_IMAGE_BASE}-hello-world:${PYTHON_MINOR}-${OS_VERSION}-${DEBIAN_NAME}-${CI_PIPELINE_ID}"
    build_test_image "${IMAGE_NAME}" "hello-world"
    test_docker_output "${IMAGE_NAME}" "hello there"
fi

if [[ ${target} == "gunicorn" ]] || [[ ${target} == "ALL" ]]; then
    test_run=1
    IMAGE_NAME="${TEST_IMAGE_BASE}-gunicorn:${PYTHON_MINOR}-${OS_VERSION}-${DEBIAN_NAME}-${CI_PIPELINE_ID}"
    build_test_image "${IMAGE_NAME}" "gunicorn"
    test_docker_http "${IMAGE_NAME}" "flask/gunicorn"
fi

if [[ ${target} == "fastapi" ]] || [[ ${target} == "ALL" ]]; then
    test_run=1
    IMAGE_NAME="${TEST_IMAGE_BASE}-fastapi:${PYTHON_MINOR}-${OS_VERSION}-${CI_PIPELINE_ID}"
    build_test_image "${IMAGE_NAME}" "fastapi"
    test_docker_http "${IMAGE_NAME}" "I am alive"
fi

if [[ ${target} == "pandas" ]] || [[ ${target} == "ALL" ]]; then
    test_run=1
    IMAGE_NAME="${TEST_IMAGE_BASE}-pandas:${PYTHON_MINOR}-${OS_VERSION}-${DEBIAN_NAME}-${CI_PIPELINE_ID}"
    build_test_image "${IMAGE_NAME}" "pandas"
    test_docker_output "${IMAGE_NAME}" "The Mainframe says: 2"
fi

if [[ ${target} == "google-cloud" ]] || [[ ${target} == "ALL" ]]; then
    test_run=1
    . ./tests/google-cloud/test_google_cloud.sh
    IMAGE_NAME="${TEST_IMAGE_BASE}-google-cloud:${PYTHON_MINOR}-${OS_VERSION}-${DEBIAN_NAME}-${CI_PIPELINE_ID}"
    build_test_image "${IMAGE_NAME}" "google-cloud"
    test_google_cloud_image "${IMAGE_NAME}" "Topic \[projects/made-up-project/topics/alexos-distroless-python-test\]"
fi

if [[ ${target} == "kubernetes" ]] || [[ ${target} == "ALL" ]]; then
    test_run=1
    . ./tests/kubernetes/test_kubernetes.sh
    IMAGE_NAME="${TEST_IMAGE_BASE}-kubernetes:${PYTHON_MINOR}-${OS_VERSION}-${DEBIAN_NAME}-${CI_PIPELINE_ID}"
    build_test_image "${IMAGE_NAME}" "kubernetes"
    test_kubernetes_image "${IMAGE_NAME}" "Event: MODIFIED distroless-python-test-${PYTHON_MINOR}-${OS_VERSION}"
fi


# ----------------------------------------------------------

if [[ $failures -gt 0 ]]; then
    _console_msg "Oh no, ${failures} tests FAILED. See output above for more detail" ERROR
    exit 1
elif [[ $test_run == 1 ]]; then
    _console_msg "Success - all tests PASSED" INFO
else
    _console_msg "No tests ran - did you specify a valid test with the --target switch?" WARN
fi

popd > /dev/null || exit
