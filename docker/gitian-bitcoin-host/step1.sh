#!/bin/bash
set -e

if [[ -z "$VERSION" ]]; then
	echo "Please define VERSION environment variable for bitcoin checkout" 1>&2
	exit 1
fi

source ~/.bash_profile

git clone https://github.com/bitcoin/bitcoin.git
cd bitcoin
git checkout v${VERSION}
cd ../gitian-builder
mkdir -p var
if [ ! -e var/id_dsa ]; then
  ssh-keygen -t dsa -f var/id_dsa -N ""
fi

export MIRROR_HOST=$GITIAN_HOST_IP
SUITE=precise

## build both VMs in parallel
echo -e "MIRROR_HOST=$GITIAN_HOST_IP bin/make-base-vm --lxc --arch i386 --suite $SUITE\nMIRROR_HOST=$GITIAN_HOST_IP bin/make-base-vm --lxc --arch amd64 --suite $SUITE" | parallel -j2 || exit $?

function ext_partition() {
	local OUT=$1
	echo Extracting $OUT partition for lxc
	qemu-img convert $OUT.qcow2 $OUT.raw
 	loop=`sudo kpartx -av $OUT.raw|sed -n '/loop.p1/{s/.*loop\(.\)p1.*/\1/;p}'`
	sudo cp --sparse=always /dev/mapper/loop${loop}p1 $OUT
	sudo chown $USER $OUT
	sudo sync
	sleep 5
	sudo kpartx -d /dev/loop$loop
	sudo rm /dev/mapper/loop${loop}p1
	rm -f $OUT.raw
}

ext_partition base-${SUITE}-i386 && \
ext_partition base-${SUITE}-amd64 || exit $?
