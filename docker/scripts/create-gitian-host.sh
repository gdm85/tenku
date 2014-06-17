#!/bin/bash

BASENAME=$(dirname $(readlink -m $0))

cd $BASENAME/../gitian-host || exit $?

if [ ! -f authorized_keys ]; then
	echo "No authorized_keys file found in $PWD"
	if [ -f ~/.ssh/id_rsa.pub ]; then
		echo -n "Do you want to use ~/.ssh/id_rsa.pub? (y/n) "
		read -r ANSWER
		if [[ "$ANSWER" == "y" ]]; then
			cp -v ~/.ssh/id_rsa.pub authorized_keys || exit $?
		else
			exit 1
		fi
	else
		exit 1
	fi
fi

function wait_for_ssh() {
	local IP="$1"
	local SECS="$2"
	while [ $SECS -gt 0 ]; do
		ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no debian@$IP ls >/dev/null 2>/dev/null && return 0
		sleep 1
		let SECS-=1
	done
	return 1
}

function wait_remove() {
	local CID="$1"
	while [ ! docker rm $CID 2>/dev/null ]; do
		sleep 2
	done
}

##NOTE: can leave behind a running container of gitian-host
docker build --tag=gdm85/gitian-host . && \
CID=$(docker run -d --privileged gdm85/gitian-host) && \
echo "Now building base VMs" && \
IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CID) && \
wait_for_ssh $IP 10 && \
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no debian@$IP ./build-base-vms.sh && \
docker kill $CID && \
docker wait $CID && \
docker commit $CID gdm85/gitian-host-vms && \
sleep 3 && wait_remove $CID && \
echo "Gitian host images created successfully!" && \
echo "You can now spawn containers with spawn-gitian-host.sh"
