#!/usr/bin/env bash

set -euo pipefail

apt-get update
apt-get upgrade --assume-yes

apt-get install --assume-yes --no-install-recommends \
  prometheus
