#!/usr/bin/env sh

set -eu

# enable IPv4 networking
# https://wiki.turris.cz/en/public/lxc_alpine
mount -t proc proc proc/
ifconfig eth0 192.168.1.155 netmask 255.255.255.0 up
route add default gw 192.168.1.1
echo "nameserver 192.168.1.1" > /etc/resolv.conf

apk update

apk add --upgrade apk-tools
apk upgrade --available

# install packages
apk add \
  openrc \
  prometheus \
  prometheus-openrc

rc-update add bootmisc boot
rc-update add networking
rc-update add prometheus
