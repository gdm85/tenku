#!/bin/bash
## automatic Gitian build of bitcoin
## @author gdm85
## @version 0.3.1
## see also https://github.com/gdm85/tenku/blob/master/docker/gitian-bitcoin-host/
##
#

if [ $# -lt 2 ]; then
	echo "Usage: build-bitcoin.sh commit linux [win] [osx] [...]" 1>&2
	exit 1
fi

COMMIT="$1"
shift
## remaining parameters are OS targets to be build (e.g. win,osx,linux)

CLONE="$HOME/bitcoin"

function verlte() {
    [  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}

NPROC=$(nproc) && \
cd gitian-builder && \
mkdir -p inputs && \
cd .. || exit $?

if [ ! -d bitcoin ]; then
	git clone https://github.com/bitcoin/bitcoin.git && \
	cd bitcoin && \
	git checkout $COMMIT && \
	cd .. || exit $?
fi

## old logic using descriptors (only linux supported)
if echo "$COMMIT" | grep ^v >/dev/null && ! verlte v0.10.0rc1 $COMMIT; then
	## make sure only Linux is being built
	if [[ ! $# -eq 1 && "$1" != "linux" ]]; then
		echo "For versions before 0.10.0rc1, only Linux building is supported" 1>&2
		exit 1
	fi

	VERSION=$(echo "$COMMIT" | awk '{ print substr($0, 2) }')

	cd gitian-builder/inputs || exit $?
	## get each dependency
	## they are validated afterwards by gbuild
	while read -r URL FNAME; do
	        if [ -z "$URL" ]; then
	                continue
	        fi
	        if [ ! -f $FNAME ]; then
	                echo "echo 'Downloading $FNAME'"
	                echo "wget -q --no-check-certificate '$URL' -O '$FNAME' || echo 'Failed to download $FNAME from $URL'"
	        fi
	done < ../../input-sources/${VERSION}-inputs.txt | parallel -j10 || exit $?

	## verify that all sources are correct before continuing
	md5sum -c < ../../input-sources/${VERSION}-inputs.md5 && \
	DESCRIPTORS="$(<../input-sources/${VERSION}-descriptors.txt)" && \
	cd .. || exit $?

	for DESC in $DESCRIPTORS; do
		./bin/gbuild -j$NPROC ../bitcoin/contrib/gitian-descriptors/${DESC}.yml && \
		mv -v $(find build/out -type f -name '*gz' -o -name '*.zip') inputs/ || exit $?
	done
else
	cd bitcoin/depends || exit $?
	for DESC in $@; do
		make download-${DESC} SOURCES_PATH="$HOME/gitian-builder/cache/common" || exit $?
	done
	cd ../.. || exit $?
fi

## proceed to build of each of the specified gitian descriptors
cd gitian-builder || exit $?
for DESC in $@; do
	./bin/gbuild -j$NPROC --commit bitcoin=$COMMIT -u bitcoin=$CLONE "$CLONE/contrib/gitian-descriptors/gitian-${DESC}.yml" || exit $?
done

echo "Successfully built gitian-${DESC} at $COMMIT"
