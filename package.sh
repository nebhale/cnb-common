#!/usr/bin/env bash

set -euo pipefail

if [[ -d $PWD/go-module-cache && ! -d ${GOPATH}/pkg/mod ]]; then
  mkdir -p ${GOPATH}/pkg
  ln -s $PWD/go-module-cache ${GOPATH}/pkg/mod
fi

cd "$(dirname "${BASH_SOURCE[0]}")/../source"

git fetch --tags

ID=$(sed -n 's|id      = \"\(.*\)\"|\1|p' buildpack.toml | head -n1)
VERSION="$(git describe --tags)"
VERSION="${VERSION:1}"

go build -ldflags='-s -w' -o bin/package github.com/cloudfoundry/libcfbuildpack/packager
bin/package \
  --archive \
  --version "${VERSION}" \
  "../package/${ID}/${ID}-${VERSION}"
