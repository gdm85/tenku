#!/bin/bash

if [ $# -lt 1 ]; then
	echo "Usage: gitian-build.sh linux [win] [osx] [...]" 1>&2
	exit 1
fi

PARALLEL=""
if type coshell 2>/dev/null >/dev/null; then
	PARALLEL="coshell"
else
	if type parallel 2>/dev/null >/dev/null; then
		PARALLEL="parallel -j$#"
	else
		echo "Please install coshell (https://github.com/gdm85/coshell) or GNU Parallel (https://www.gnu.org/software/parallel/)" 1>&2
		exit 2
	fi
fi

set -o pipefail && \
MOSTRECENT="$(curl -s https://api.github.com/repos/bitcoin/bitcoin/tags | jq -r '.[0].name' | awk '{ print substr($0, 2) }')" || exit $?

## run all necessary containers, detached
function run_all() {
	local OS

	for OS in "$@"; do
		echo "docker run -d --privileged gdm85/gitian-bitcoin-host"
	done | $PARALLEL
}

## run a simple test to detect if SSH works
function loop_wait_all() {
	local RETRIES="$1"
	shift
	while [ $RETRIES -gt 0 ]; do
		wait_all "$@" && break
		sleep 1
		let RETRIES-=1
	done
	return 0
}

function wait_all() {
	local CID
	local IP

	for CID in "$@"; do
		IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CID) && \
	    	echo "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no debian@$IP true" || return $?
	done | $PARALLEL 2>/dev/null
}

function build_all() {
	local ALL=($@)
	local LEN=$(($#/2))
	local CREATED=("${ALL[@]:0:$LEN}")
	local OSES=("${ALL[@]:$LEN}")
	local CID
	local OS
	local IP

	local I=0
	for CID in $CREATED; do
		OS=${OSES[$I]}
#		IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CID) && \
#	    	echo -n "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no debian@$IP " && \
#		echo "./build-bitcoin.sh $MOSTRECENT ${OS}" || return $?
		echo "docker-enter $CID su -c 'cd /home/debian && ./build-bitcoin.sh $MOSTRECENT ${OS}' debian"
		let I+=1
	done | $PARALLEL
}

function copy_all() {
	local OS
	for OS in "$@"; do
		echo "docker cp ${CID}:/home/debian/gitian-build/build/out built-${OS}"
	done | $PARALLEL
}

CREATED="$(run_all $@ | tr '\n' ' ')" && \
echo loop_wait_all 5 $CREATED && \
echo "Containers are online: $CREATED, building bitcoin v$MOSTRECENT" && \
build_all $CREATED $@ && \
copy_all $CREATED
RV=$?

## cleanup
#echo "Cleaning up created containers..."
#for CID in $CREATED; do
#	docker stop $CID
#	docker rm $CID
#done

## return build exit code
exit $RV
