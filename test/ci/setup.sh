#!/usr/bin/env bash

set -ev

sudo apt-get -qq update

curl -O https://prerelease.keybase.io/keybase_amd64.deb

set +e
# this command will exit with 1, so don't let it take down the job with it
sudo dpkg -i keybase_amd64.deb
set -e

run="/run/user/$(id -u "${USER}")/keybase"
mnt="${run}/kbfs"

sudo apt-get install -f
sudo mkdir -p "${mnt}"
sudo chown -R "${USER}" "${run}"

keybase service &

sleep 3

kbfsfuse "${mnt}" &

sleep 3

keybase oneshot
