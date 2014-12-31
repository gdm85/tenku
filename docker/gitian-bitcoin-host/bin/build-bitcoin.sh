#!/bin/bash
## automatic Gitian build of bitcoin
## @author gdm85
## @version 0.3.1
## see also https://github.com/gdm85/tenku/blob/master/docker/gitian-bitcoin-host/
##
#

if [[ ! $# -eq 1 ]]; then
	echo "Please specify version" 1>&2
	exit 1
fi

VERSION="$1"

CLONE="$HOME/bitcoin"

function verlte() {
    [  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}

cd gitian-builder && \
mkdir -p inputs && \
cd .. || exit $?

if [ ! -d bitcoin ]; then
	git clone https://github.com/bitcoin/bitcoin.git && \
	cd bitcoin && \
	git checkout v$VERSION && \
	cd .. || exit $?
fi

## old logic using descriptors
if ! verlte 0.10.0rc1 ${VERSION}; then
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
		./bin/gbuild ../bitcoin/contrib/gitian-descriptors/${DESC}.yml && \
		mv -v $(find build/out -type f -name '*gz' -o -name '*.zip') inputs/ || exit $?
	done
else
	cd bitcoin/depends && \
	make download-linux SOURCES_PATH="$HOME/gitian-builder/cache/common" && \
	cd ../.. || exit $?
fi

## proceed to build
cd gitian-builder && \
./bin/gbuild -u bitcoin=$CLONE $CLONE/contrib/gitian-descriptors/gitian-linux.yml && \
echo "Build completed successfully, output files are in: ~/gitian-builder/build/out/"
