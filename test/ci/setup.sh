#!/usr/bin/env bash

set -ev

sudo apt-get -qq update

curl -O https://prerelease.keybase.io/keybase_amd64.deb

set +e
# this command will exit with 1, so don't let it take down the job with it
sudo dpkg -i keybase_amd64.deb
set -e

sudo apt-get install -f
sudo apt-get install expect

run_keybase

sleep 3

# the device name here is just the current timestamp, down to the milliseconds.
# this is sufficient, since the CI is configured to only run one process at a time,
# and devices are deprovisioned immediately after all tests complete.
device_name=$(date +%s%3N)

# NOTE: it's VERY IMPORTANT that no output from this command appear in public logs,
# since `keybase login` echoes the paperkey back to the terminal. If the paperkey gets leaked,
# anybody can fiddle with the CI account.
expect ./test/ci/setup.expect "${device_name}" > /dev/null 2>&1

sleep 3
