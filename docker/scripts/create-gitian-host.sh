#!/bin/bash

BASENAME=$(dirname $(readlink -m $0))

function wait_for_ssh() {
       local IP="$1"
       local SECS="$2"
       while [ $SECS -gt 0 ]; do
               ssh -o ConnectTimeout=1 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no debian@$IP ls >/dev/null 2>/dev/null && return 0
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

##NOTE: can leave behind a running container of gitian-host
docker build --tag=gdm85/gitian-host . && \
CID=$(docker run -d --privileged gdm85/gitian-host) && \
IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CID) && \
wait_for_ssh "$IP" 10 && \
echo "$CID is now online ($IP), building base VMs on it" && \
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no debian@$IP bash -c 'cd /home/debian && source ./.bash_profile && ./build-base-vms.sh amd64' && \
docker kill $CID && \
docker wait $CID && \
docker commit $CID gdm85/gitian-host-vms && \
wait_remove $CID && \
echo "Gitian host images created successfully!" && \
echo "You can now spawn containers with spawn-gitian-host.sh"
