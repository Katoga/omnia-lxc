#!/usr/bin/env sh

set -eu
set -x

lxc_scripts_root="$(pwd)"
readonly lxc_scripts_root

# create container
sudo lxc-create --name "$lxc_app" --template download -- --dist "$lxc_dist" --release "$lxc_release" --arch armv7l

# set MAC for static IP purposes
if [[ ${lxc_mac:-} ]]; then
  sudo sed -Ei "s~(lxc\.net\.0\.hwaddr = ).+\$~\\1${lxc_mac}~" "/srv/lxc/${lxc_app}/config"
fi

# copy init stuff to container FS
sudo rsync -r "${lxc_scripts_root}/${lxc_app}/" "/srv/lxc/${lxc_app}/rootfs/"

echo "${lxc_app}" | sudo tee "/srv/lxc/${lxc_app}/rootfs/etc/hostname"

# start container
sudo lxc-start --name "$lxc_app"

# give it some time to spin up
sleep 5

# run init script
if [[ -x "${lxc_scripts_root}/${lxc_app}/usr/sbin/init.sh" ]]; then
  sudo lxc-attach --name "$lxc_app" -- /usr/sbin/init.sh
fi
