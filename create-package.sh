#!/usr/bin/env bash

set -euo pipefail

if [[ -d $PWD/cnb-packager-cache && ! -d ${HOME}/.cnb-packager-cache ]]; then
  mkdir -p ${HOME}
  ln -s $PWD/cnb-packager-cache ${HOME}/.cnb-packager-cache
fi

export GOPATH=$PWD/go-module-cache

if [[ -d $PWD/pack-cache && ! -d ${HOME}/.pack ]]; then
  mkdir -p ${HOME}
  ln -s $PWD/pack-cache ${HOME}/.pack
fi

ROOT="$(realpath $(dirname "${BASH_SOURCE[0]}")/..)"

build() {
  pushd "${ROOT}/source" > /dev/null
    printf "➜ Building Buildpack\n"

    local VERSION="$(git describe --tags)"
    local VERSION="${VERSION:1}"

    $(go env GOPATH)/bin/packager \
      --global_cache \
      --version "${VERSION}" \
      "${ROOT}/build"
  popd > /dev/null
}

pack() {
  pushd "${ROOT}/pack" > /dev/null
    local ARCHIVE="$(ls pack-*.tgz)"

    printf "➜ Expanding ${ARCHIVE}\n"
    tar xzf "${ARCHIVE}"
  popd > /dev/null
}

package() {
  yj -tj < "${ROOT}/build/buildpack.toml" | \
    jq '{
      buildpack: {
        uri: "build"
      },
      stacks: .stacks
    }' | yj -jt > "package.toml"

  pack/pack \
    create-package \
    localhost:5000/builder \
    -p package.toml \
    --publish

    crane pull localhost:5000/builder "image/image.tar"
}

packager() {
  printf "➜ Building Packager\n"
  go get github.com/cloudfoundry/libcfbuildpack/packager
  go build -ldflags="-s -w" github.com/cloudfoundry/libcfbuildpack/packager
}

registry() {
  printf "➜ Starting Registry\n"
  docker-registry serve /etc/docker/registry/config.yml &> /dev/null &
}

tag() {
    local VERSION=$(yj -tj < "${ROOT}/build/buildpack.toml" | jq -r '.buildpack.version')

    printf "➜ Creating Tag ${VERSION}\n"
    echo $VERSION > "image/tags"
}

packager
build

pack
registry
package
tag
