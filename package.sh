#!/usr/bin/env bash

set -euo pipefail

if [[ -d $PWD/go-module-cache && ! -d ${GOPATH}/pkg/mod ]]; then
  mkdir -p ${GOPATH}/pkg
  ln -s $PWD/go-module-cache ${GOPATH}/pkg/mod
fi

if [[ -d $PWD/cnb-packager-cache && ! -d ${HOME}/.cnb-packager-cache ]]; then
  mkdir -p ${HOME}
  ln -s $PWD/cnb-packager-cache ${HOME}/.cnb-packager-cache
fi

if [[ ! -d ${HOME}/.netrc ]]; then
  mkdir -p ${HOME}
  echo "machine github.com
login ${USERNAME}
password ${PASSWORD}" > ${HOME}/.netrc
fi

cd "$(dirname "${BASH_SOURCE[0]}")/../source"

ID=$(sed -n 's|id      = \"\(.*\)\"|\1|p' buildpack.toml | head -n1)
VERSION="$(git describe --tags)"
VERSION="${VERSION:1}"

go build -ldflags='-s -w' -o bin/package github.com/cloudfoundry/libcfbuildpack/packager
bin/package \
  --archive \
  --global_cache \
  --version "${VERSION}" \
  "../package/${ID}-${VERSION}"
echo "${VERSION}" > "../package/version"
