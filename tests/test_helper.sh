#!/usr/bin/env bash
set -ouE pipefail

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "-> [ERROR] This script should be sourced, not run directly"
    exit 1
fi


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
