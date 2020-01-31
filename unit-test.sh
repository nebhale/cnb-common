#!/usr/bin/env bash

set -euo pipefail
source common.sh










cd "${ROOT}/source"

go test ./...
