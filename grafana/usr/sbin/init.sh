#!/usr/bin/env bash

set -euo pipefail

apt-get update
apt-get upgrade --assume-yes

apt-get install --assume-yes --no-install-recommends \
  apt-transport-https \
  curl \
  gnupg \
  prometheus-node-exporter \
  software-properties-common

mkdir -p /etc/apt/keyrings/

curl -LfSs https://apt.grafana.com/gpg.key \
| gpg --dearmor \
> /etc/apt/keyrings/grafana.gpg

echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" >> /etc/apt/sources.list.d/grafana.list

apt-get update
apt-get install --assume-yes --no-install-recommends \
  grafana

sed -Ei 's~;(domain =) localhost~\1 grafana.lan~' /etc/grafana/grafana.ini

# disable call-home, see https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/#analytics
sed -Ei 's~;?(reporting_enabled|check_for_updates|check_for_plugin_updates)\s*.+~\1 = false~' /etc/grafana/grafana.ini

# activate
systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server
