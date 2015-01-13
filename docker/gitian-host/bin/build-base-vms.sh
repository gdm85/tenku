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

function retry_remove() {
	local RETRIES="$1"
	local LOOP="$2"
	while ! sudo losetup -d "/dev/loop${LOOP}" 2>/dev/null; do
		let RETRIES-=1
		if [ $RETRIES -eq 0 ]; then
			echo "Failed removing /dev/loop${LOOP}" 1>&2
			return 1
		fi
		sleep 1
	done
	sudo unlink /dev/mapper/loop${LOOP}p1 2>/dev/null
}

## this function corresponds to part removed from gbuild via custom patch
function ext_partition() {
	local loop
	local OUT=$1
	echo "Converting $OUT to raw format..." && \
	qemu-img convert $OUT.qcow2 $OUT.raw && \
	echo -n "Identifying partition..." && \
	set -o pipefail && \
 	loop=`sudo kpartx -av $OUT.raw | sed -n '/loop.p1/{s/.*loop\(.\)p1.*/\1/;p}'` && \
	echo ": $loop" && \
	echo "Copying partition to $OUT..." && \
	sudo cp --sparse=always /dev/mapper/loop${loop}p1 $OUT && \
	sudo chown $USER $OUT || return $?
	## these are silenced because if former fails, second doesn't and viceversa
	echo "Removing partition loop mount..." && \
	retry_remove 5 "$loop" && \
	echo "Removing raw image..." && \
	rm -f "$OUT.raw" && \
	echo "$OUT correctly extracted"
}

for TYPE in "$@"; do
	ext_partition base-${SUITE}-${TYPE} || exit $?
done
