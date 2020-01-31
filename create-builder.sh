#!/usr/bin/env bash

set -euo pipefail
source common.sh

builder() {
  printf "➜ Creating Builder\n"

  pack/pack \
    create-builder \
    localhost:5000/builder \
    -b builder.toml \
    --publish

  crane pull localhost:5000/builder "image/image.tar"
}















# buildpacks() {
#   pushd "${ROOT}/package" > /dev/null
#     local ARCHIVE="$(ls *.tgz)"
#     printf "➜ Expanding ${ARCHIVE}\n"

#     tar xzf "${ARCHIVE}"
#     rm "${ARCHIVE}"

#     for D in $(find dependency-cache/* -type d) ; do
#       pushd "${D}" > /dev/null
#         local ARCHIVE="$(ls *.tgz)"
#         printf "➜ Expanding ${ARCHIVE}\n"

#         tar xzf "${ARCHIVE}"
#         rm "${ARCHIVE}"
#       popd > /dev/null
#     done
#   popd > /dev/null
# }

# order() {
#   printf "➜ Creating order.toml\n"

#   yj -tj < "${ROOT}/package/buildpack.toml" | \
#     jq '{
#       buildpacks: [.metadata.dependencies[] | {id: .id, uri: "package/dependency-cache/\(.sha256)"}],
#       order: .order,
#       stack: .stack
#     }' | yj -jt > "order.toml"
# }

# tag() {
#   printf "➜ Creating Tag $(cat package/version)\n"
#   mkdir -p "image"
#   cp "package/version" "image/tags"
# }

pack
registry
builder

# buildpacks
# order
# tag
