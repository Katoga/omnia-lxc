#!/usr/bin/env bash

set -euo pipefail

sudo apt-get update
sudo apt-get upgrade --assume-yes

sudo apt-get install --assume-yes \
  apt-transport-https \
  software-properties-common

sudo mkdir -p /etc/apt/keyrings/

curl -LfSs https://apt.grafana.com/gpg.key \
| gpg --dearmor \
| sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

sudo apt-get update
sudo apt-get install --assume-yes \
  grafana

# 22:52:f7:28:ed:9d
