#!/usr/bin/env bash

set -euxo pipefail

if [[ -d $PWD/go-module-cache && ! -d ${GOPATH}/pkg/mod ]]; then
  mkdir -p ${GOPATH}/pkg
  ln -s $PWD/go-module-cache ${GOPATH}/pkg/mod
fi

sha256() {
  cat "../${DEPENDENCY}/sha256"
}

uri() {
  cat "../${DEPENDENCY}/uri"
}

version() {
  cat "../${DEPENDENCY}/version"
}


cd "$(dirname "${BASH_SOURCE[0]}")/../source"
[ -f "scripts/update-dependency.sh" ] && source "scripts/update-dependency.sh"

go build -ldflags='-s -w' -o bin/dependency github.com/cloudfoundry/libcfbuildpack/dependency
bin/dependency \
  "${DEPENDENCY}" \
  "[\d]+\.[\d]+(?:\.[\d]+)?" \
  "$(version)" \
  "$(uri)" \
  "$(sha256)"

git \
  -c user.name='Pivotal Java Experience Team' \
  -c user.email='cfje@pivotal.io' \
  commit \
  --signoff \
  --all \
  --message "Dependency Upgrade: ${DEPENDENCY} $(version)"
