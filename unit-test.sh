#!/usr/bin/env bash

set -euo pipefail
source $(dirname $0)/common.sh

cd "${ROOT}/source"

[[ -z "$(find . -name "*.go")" ]] && exit
go test ./...
