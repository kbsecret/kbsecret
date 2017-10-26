#!/usr/bin/env bash

set -ev

set +e
# ideally this would never fail, but who knows?
rm -rf /keybase/private/kbsecretci/*
set -e

expect ./test/ci/teardown.expect
