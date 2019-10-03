#!/usr/bin/env bash

set -euo pipefail

if [[ -d $PWD/pack-cache && ! -d ${HOME}/.pack ]]; then
  mkdir -p ${HOME}
  ln -s $PWD/pack-cache ${HOME}/.pack
fi

ROOT="$(dirname "${BASH_SOURCE[0]}")/.."

builder() {
  printf "\n➜  Creating Builder\n"

  "pack/pack" \
    create-builder \
    localhost:5000/builder \
    -b order.toml \
    --publish

  mkdir -p "image"
  crane pull localhost:5000/builder "image/image.tar"
}

buildpacks() {
  pushd "${ROOT}/package" > /dev/null
    local ARCHIVE="$(ls *.tgz)"
    printf "\n➜  Expanding ${ARCHIVE}\n"

    tar xzf "${ARCHIVE}"
    rm "${ARCHIVE}"

    for D in $(find dependency-cache/* -type d) ; do
      pushd "${D}" > /dev/null
        local ARCHIVE="$(ls *.tgz)"
        printf "➜    Expanding ${ARCHIVE}\n"

        tar xzf "${ARCHIVE}"
        rm "${ARCHIVE}"
      popd > /dev/null
    done
  popd > /dev/null
}

order() {
  printf "\n➜  Creating order.toml\n"

  yj -tj < "${ROOT}/package/buildpack.toml" | \
    jq '{
      buildpacks: [.metadata.dependencies[] | {id: .id, uri: "package/dependency-cache/\(.sha256)"}],
      order: .order,
      stack: .stack
    }' | yj -jt > "order.toml"
}

pack() {
  pushd "${ROOT}/pack" > /dev/null
    local ARCHIVE="$(ls pack-*.tgz)"

    printf "\n➜  Expanding ${ARCHIVE}\n"
    tar xzf "${ARCHIVE}"
  popd > /dev/null
}

registry() {
  printf "\n➜  Starting Registry\n"
  docker-registry serve /etc/docker/registry/config.yml &> /dev/null &
}

tag() {
  printf "\n➜  Creating Tag $(cat package/version)\n"
  mkdir -p "image"
  cp "package/version" "image/tags"
}

pack
buildpacks
order
registry
builder
tag
