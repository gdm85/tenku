#!/bin/bash

if [ $# -eq 0 ]; then
	echo "Please specify: [i386|amd64]" 1>&2
	exit 1
fi

if [ -z "$USE_LXC" ]; then
	echo "Environment variables not correctly setup (source .bash_profile?)" 1>&2
	exit 2
fi

export MIRROR_HOST=$GITIAN_HOST_IP
SUITE=precise

cd gitian-builder && \
mkdir -p var || exit $?

if [ ! -e var/id_dsa ]; then
  ssh-keygen -t dsa -f var/id_dsa -N ""
fi

## build both VMs in parallel
for TYPE in "$@"; do
	echo -e "MIRROR_HOST=$GITIAN_HOST_IP bin/make-base-vm --lxc --arch $TYPE --suite $SUITE"
done | parallel -j$# || exit $?

## this function corresponds to part removed from gbuild via custom patch
function ext_partition() {
	local OUT=$1
	echo "Extracting $OUT partition for lxc" && \
	qemu-img convert $OUT.qcow2 $OUT.raw && \
 	loop=`sudo kpartx -av $OUT.raw|sed -n '/loop.p1/{s/.*loop\(.\)p1.*/\1/;p}'` || return $?
	sudo cp --sparse=always /dev/mapper/loop${loop}p1 $OUT && \
	sudo chown $USER $OUT || return $?
	## following 2 lines are a sloppy hack to an unknown problem with kpartx
	sudo sync && \
	sleep 5 || return $?
	## these are silenced because if former fails, second doesn't and viceversa
	sudo kpartx -d /dev/loop$loop 2>/dev/null && \
	sudo rm /dev/mapper/loop${loop}p1 2>/dev/null && \
	rm -f $OUT.raw
}

for TYPE in "$@"; do
	ext_partition base-${SUITE}-${TYPE} || exit $?
done
