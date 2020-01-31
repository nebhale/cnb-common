ROOT="$(realpath $(dirname "${BASH_SOURCE[0]}")/..)"

if [[ -d $PWD/cnb-packager-cache && ! -d ${HOME}/.cnb-packager-cache ]]; then
  mkdir -p ${HOME}
  ln -s $PWD/cnb-packager-cache ${HOME}/.cnb-packager-cache
fi

if [[ -d $PWD/go-cache ]]; then
  export GOPATH=$PWD/go-cache
fi

if [[ -d $PWD/pack-cache && ! -d ${HOME}/.pack ]]; then
  mkdir -p ${HOME}
  ln -s $PWD/pack-cache ${HOME}/.pack
fi

pack() {
  pushd "${ROOT}/pack" > /dev/null
    local ARCHIVE="$(ls pack-*.tgz)"

    printf "➜ Expanding ${ARCHIVE}\n"
    tar xzf "${ARCHIVE}"
  popd > /dev/null
}

registry() {
  printf "➜ Starting Registry\n"
  docker-registry serve /etc/docker/registry/config.yml &> /dev/null &
}
