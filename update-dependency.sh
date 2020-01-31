#!/usr/bin/env bash

set -euo pipefail
source $(dirname $0)/common.sh











sha256() {
  cat "../dependency/sha256"
}

uri() {
  cat "../dependency/uri"
}

version() {
  cat "../dependency/version"
}

cd "${ROOT}/source"
[ -f "scripts/update-dependency.sh" ] && source "scripts/update-dependency.sh"

go build -ldflags='-s -w' -o bin/dependency github.com/cloudfoundry/libcfbuildpack/dependency
bin/dependency \
  "${DEPENDENCY}" \
  "${VERSION_PATTERN}" \
  "$(version)" \
  "$(uri)" \
  "$(sha256)"

git add buildpack.toml
git checkout -- .

git \
  -c user.name='Pivotal Java Experience Team' \
  -c user.email='cfje@pivotal.io' \
  commit \
  --signoff \
  --message "Dependency Upgrade: ${DEPENDENCY} $(version)"
