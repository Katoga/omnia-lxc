#!/usr/bin/env bash

set -euo pipefail

apt-get update
apt-get upgrade --assume-yes

apt-get install --assume-yes --no-install-recommends \
  prometheus \
  prometheus-node-exporter

cp -f /opt/prometheus/prometheus.yml /etc/prometheus/prometheus.yml

systemctl reload prometheus
