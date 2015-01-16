#!/bin/bash
## bitcoin-gitian-build.sh
##
## @author gdm85
##
## Automatically build latest version of Bitcoin Core using
## Docker containers (nested LXC).
##
## User can specify target operative systems as arguments.
## Several optional environment variables condition the build:
## - OUTPUTDIR - where input/output volume directories will be read/created
## - SIGNER - id of signer (no signature will be attempted, just directory structure created)
## - COMMIT - commit/branch to use for build, by default is latest tag
## - NOPURGE - set to non-empty to not dispose containers after build
#

SCRIPTS=$(dirname $(readlink -m $0)) || exit $?

## place this file in script's directory in order to build for Mac OS X
SDK=MacOSX10.7.sdk.tar.gz

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

function read_commit() {
	local SHA="$1"
	local OUTPUT
	set -o pipefail && \
	OUTPUT=$(curl -s https://api.github.com/repos/bitcoin/bitcoin/commits/${SHA} | jq -r '.sha') && \
	test ! -z "$OUTPUT" && \
	test "$OUTPUT" != "null" && \
	echo "$OUTPUT"
}

## run all necessary containers, detached
## setup proper volumes for input/output collection
function run_all() {
	local OS

	for OS in "$@"; do
		mkdir -p "$LSOURCE/${OS}" && \
		rm -rf "$LDEST/${OS}" && \
		mkdir -p "$LDEST/${OS}" || return $?
	done
	mkdir -p "$LSIGS" && \
	mkdir -p "$LSOURCE" && \
	mkdir -p "$LRESULT" && \
	chown -R 1000.1000 "$LDEST" "$LSOURCE" "$LSIGS" "$LRESULT" || return $?

	for OS in "$@"; do
		echo "docker run -d --privileged -v $LRESULT:$CRESULT -v $LSIGS:$CSIGS -v $LSOURCE/${OS}:${CSOURCE} -v $LDEST/${OS}:$CDEST gdm85/gitian-bitcoin-host" || return $?
	done | $PARALLEL
}

function inject_mac_sdk() {
	local CID="$1"

	docker-inject "$CID" "$SCRIPTS/$SDK" /home/debian/gitian-builder/inputs/
}

function build_all() {
	local ALL=($@)
	local COUNT=$#
	local LEN=$((COUNT/2))
	local CREATED=(${ALL[@]:0:$LEN})
	local OSES=(${ALL[@]:$LEN})
	local CID
	local OS

	local I=0
	for CID in "${CREATED[@]}"; do
		OS=${OSES[$I]}

		if [[ "$OS" == "osx" ]]; then
			inject_mac_sdk "$CID" || return $?
		fi
		let I+=1
	done

	I=0
	for CID in "${CREATED[@]}"; do
		OS=${OSES[$I]}
		local OS_LOG_FILE="$LLOGS/build-${OS}.log"
		echo "Execution log for ${OS} ({$HCOMMIT}) --> $OS_LOG_FILE" 1>&2

		## disable /dev/kvm, just in case it is attempted to be used
		echo -n "docker exec $CID rm /dev/kvm && "
		echo -n "docker exec $CID su -c 'cd /home/debian && source .bash_profile && ./build-bitcoin.sh $COMMIT ${OS} && " && \
		echo -n "cd gitian-builder && ./bin/gasserts --signer $SIGNER --release ${HCOMMIT} --destination ../gitian.sigs/ ../bitcoin/contrib/gitian-descriptors/gitian-${OS}.yml' debian " && \
		echo    " >> $OS_LOG_FILE 2>&1"
		let I+=1
	done | $PARALLEL
}

## change the assert directory as desired
if [ -z "$SIGNER" ]; then
	SIGNER="$USER"
fi

## customize output volumes
if [ -z "$OUTPUTDIR" ]; then
	OUTPUTDIR="$SCRIPTS/output"
fi

set -o pipefail || exit $?

## always get latest release/rc if no commit environment was specified
if [ ! -z "$COMMIT" ]; then
	HCOMMIT="$COMMIT"
else
	HCOMMIT="$(curl -s https://api.github.com/repos/bitcoin/bitcoin/tags | jq -r '.[0].name')" || exit $?
fi

## get commit short hash
## NOTE: this overwrites environment provided by user
COMMIT=$(read_commit "$HCOMMIT") || exit $?

###
### declarations for input/output data volumes
###

## always add human readable commit and commit to volume path variables
REL_OD="$OUTPUTDIR/${HCOMMIT}-${COMMIT}"
LRESULT="${REL_OD}/result-${HCOMMIT}-${COMMIT}"
LSIGS="${REL_OD}/sigs"
LDEST="${REL_OD}/built"
LLOGS="${REL_OD}"
## depends-cache does not sport human readable prefix, being the only input volume for containers
LSOURCE="${OUTPUTDIR}/${COMMIT}/depends-cache"

## path of above volumes inside the containers
CRESULT="/home/debian/gitian-builder/result"
CSIGS="/home/debian/gitian.sigs"
CSOURCE="/home/debian/gitian-builder/cache"
CDEST="/home/debian/gitian-builder/build"

## ---------------- main -------------------- ##

CREATED="$(run_all $@ | tr '\n' ' ')" && \
echo "Building bitcoin (${HCOMMIT}) for $@" && \
build_all ${CREATED[@]} $@
RV=$?

if [ -z "$NOPURGE" ]; then
	## cleanup
	#echo "Cleaning up created containers..."
	for CID in $CREATED; do
		docker stop $CID
		docker rm $CID
	done
fi

## return build exit code
if [ $RV -eq 0 ]; then
	echo -n "Completed successfully "
else
	echo -n "Failed "
fi
echo "with exit code = $RV"
exit $RV
