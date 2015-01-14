#!/bin/bash
## bitcoin-gitian-build.sh
##
## @author gdm85
##
## Automatically build latest version of Bitcoin Core using
## Docker containers (LXC) + KVM.
##
## User can specify target operative systems as arguments.
##
#

SCRIPTS=$(dirname $(readlink -m $0)) || exit $?

if [ $# -lt 1 ]; then
	echo "Usage: gitian-build.sh linux [win] [osx] [...]" 1>&2
	exit 1
fi

if docker info 2>/dev/null | grep ^Storage | grep aufs$ >/dev/null; then
	echo "You are using AUFS as Docker storage drive, which is terribly broken and not supported by this script." 1>&2
	exit 1
fi

## identify a CLI tool to run commands in parallel
## coshell is preferred
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

## retrieve latest tagged release/release candidate
set -o pipefail && \
MOSTRECENT="$(curl -s https://api.github.com/repos/bitcoin/bitcoin/tags | jq -r '.[0].name' | awk '{ print substr($0, 2) }')" || exit $?

## volumes inside container that are provided externally (bind mount)
LSOURCE="$SCRIPTS/gitian-cache"
LDEST="$SCRIPTS/gitian-built"
CSOURCE="/home/debian/gitian-builder/cache"
CDEST="/home/debian/gitian-builder/build"

## run all necessary containers, detached
## setup proper volumes for input/output collection
function run_all() {
	local OS

	for OS in "$@"; do
		mkdir -p "$LSOURCE/${OS}" && \
		rm -rf "$LDEST" && \
		mkdir -p "$LDEST" || return $?
	done
	mkdir -p "$LSOURCE" "$LDEST" && \
	chown -R 1000.1000 "$LDEST" "$LSOURCE" || return $?

	for OS in "$@"; do
		echo "docker run -d --privileged -v $LSOURCE/${OS}:${CSOURCE} -v $LDEST/${OS}:$CDEST gdm85/gitian-bitcoin-host" || return $?
	done | $PARALLEL
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

		## first, fix rights of mounted volumes
		echo -n "docker exec $CID chown -R debian.debian '$CSOURCE' '$CDEST' && " && \
		echo "docker exec $CID su -c 'cd /home/debian && source .bash_profile && ./build-bitcoin.sh $MOSTRECENT ${OS}' debian"
		let I+=1
	done | $PARALLEL
}

CREATED="$(run_all $@ | tr '\n' ' ')" && \
echo "Building bitcoin v$MOSTRECENT on containers $CREATED" && \
build_all $CREATED $@ && \
echo "Build results are available in '$SCRIPTS/built/'"
RV=$?

exit $RV

## cleanup
echo "Cleaning up created containers..."
for CID in $CREATED; do
	docker stop $CID
	docker rm $CID
done

## return build exit code
exit $RV
