#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../source"

git remote add upstream ../upstream
git fetch upstream --no-tags

git \
  -c user.name='Pivotal Java Experience Team' \
  -c user.email='cfje@pivotal.io' \
  merge \
  --no-ff \
  --log \
  --no-edit \
  $(cat ../upstream/.git/ref)
