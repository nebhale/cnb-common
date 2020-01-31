#!/usr/bin/env bash

set -euo pipefail
source $(dirname $0)/common.sh

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

package() {
  printf "➜ Creating Package\n"

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
