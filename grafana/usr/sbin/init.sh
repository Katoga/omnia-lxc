#!/usr/bin/env sh

set -eu

# enable IPv4 networking
# https://wiki.turris.cz/en/public/lxc_alpine
mount -t proc proc proc/
ifconfig eth0 192.168.1.145 netmask 255.255.255.0 up
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

pkg_version=10.4.3

# build grafana-frontend
pkg_name=grafana-frontend
release_version=3.19
su katoga -c "mkdir -p /home/katoga/aports/${pkg_name}"
cd "/home/katoga/aports/${pkg_name}"
for f in APKBUILD; do
  echo "f: '${f}'"
  curl -LfSs \
    -o "$f" \
    "https://git.alpinelinux.org/aports/plain/community/${pkg_name}/${f}?h=${release_version}-stable"
done

# update version
checksum="$(curl -LfSs "https://dl.grafana.com/oss/release/grafana-${pkg_version}.linux-amd64.tar.gz" | sha512sum | cut -d ' ' -f 1)"
sed -Ei "s~^(pkgver=).+$~\1${pkg_version}~" APKBUILD
sed -Ei "s~^(pkgrel=).+$~\10~" APKBUILD
sed -Ei "s~^[0-9a-f]+(\s+grafana-frontend-)\d+\.\d+\.\d+(-bin.tar.gz)$~${checksum}\1${pkg_version}\2~" APKBUILD

chown katoga:katoga ./*

su katoga -c 'abuild -r'

# build grafana
pkg_name=grafana
release_version=3.19
su katoga -c "mkdir -p /home/katoga/aports/${pkg_name}"
cd "/home/katoga/aports/${pkg_name}"
for f in APKBUILD "${pkg_name}-cli.sh" "${pkg_name}-server.sh" "${pkg_name}.confd" "${pkg_name}.initd" "${pkg_name}.pre-install"; do
  echo "f: '${f}'"
  curl -LfSs \
    -o "$f" \
    "https://git.alpinelinux.org/aports/plain/community/${pkg_name}/${f}?h=${release_version}-stable"
done

# update version
checksum="$(curl -LfSs "https://github.com/grafana/grafana/archive/v${pkg_version}.tar.gz" | sha512sum | cut -d ' ' -f 1)"
sed -Ei "s~^(pkgver=).+$~\1${pkg_version}~" APKBUILD
sed -Ei "s~^(pkgrel=).+$~\10~" APKBUILD
sed -Ei "s~^[0-9a-f]+(\s+grafana-)\d+\.\d+\.\d+(.tar.gz)$~${checksum}\1${pkg_version}\2~" APKBUILD
sed -Ei 's~\s+!armhf~~' APKBUILD

chown katoga:katoga ./*

su katoga -c 'abuild -r'

# install packages
apk add \
  --repository /home/katoga/packages/aports \
  grafana \
  grafana-openrc \
  grafana-frontend

rc-update add grafana
