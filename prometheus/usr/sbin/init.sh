#!/usr/bin/env bash

set -euo pipefail

apt-get update
apt-get upgrade --assume-yes

apt-get install --assume-yes --no-install-recommends \
  avahi-daemon \
  avahi-dnsconfd \
  avahi-utils \
  libnss-mdns \
  prometheus \
  prometheus-node-exporter

sed -Ei 's~mdns4_minimal~mdns6~' /etc/nsswitch.conf
sed -Ei 's~(use-ipv4=)yes~\1no~' /etc/avahi/avahi-daemon.conf

cp -f /opt/prometheus/prometheus.yml /etc/prometheus/prometheus.yml

systemctl reload prometheus
