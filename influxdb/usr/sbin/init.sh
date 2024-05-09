#!/usr/bin/env sh

set -eu

# enable IPv4 networking
# https://wiki.turris.cz/en/public/lxc_alpine
mount -t proc proc proc/
ifconfig eth0 192.168.1.150 netmask 255.255.255.0 up
route add default gw 192.168.1.1
echo "nameserver 192.168.1.1" > /etc/resolv.conf

apk update
apk upgrade

apk add \
  alpine-sdk \
  curl \
  doas \
  openrc

rc-update add networking
rc-update add bootmisc boot

# prepare build environment
adduser -D katoga
adduser katoga abuild
adduser katoga wheel
echo 'permit nopass :wheel' > /etc/doas.d/doas.conf

echo 'PACKAGER="Katoga <katoga.cz@hotmail.com>"' >> /etc/abuild.conf

mkdir -p /var/cache/distfiles
chgrp abuild /var/cache/distfiles
chmod g+w /var/cache/distfiles

su katoga -c 'abuild-keygen -ain'

# build influxdb
pkg_name=influxdb
release_version=3.17
su katoga -c "mkdir -p /home/katoga/aports/${pkg_name}"
cd "/home/katoga/aports/${pkg_name}"
for f in APKBUILD "${pkg_name}.confd" "${pkg_name}.initd" "${pkg_name}.pre-install"; do
  echo "f: '${f}'"
  curl -LfSs \
    -o "$f" \
    "https://git.alpinelinux.org/aports/plain/community/${pkg_name}/${f}?h=${release_version}-stable"
done

# sed

chown katoga:katoga ./*

su katoga -c 'abuild -r'

# install packages
apk add \
  --repository /home/katoga/packages/aports \
  influxdb \
  influxdb-openrc

rc-update add influxdb
