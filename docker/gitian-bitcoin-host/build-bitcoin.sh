#!/bin/bash
## automatic Gitian build of bitcoin
## @author gdm85
## @version 0.3.0
## see also https://github.com/gdm85/tenku/blob/master/docker/gitian-bitcoin-host/
##
#

if [[ ! $# -eq 1 ]]; then
	echo "Please specify version" 1>&2
	exit 1
fi

VERSION="$1"

if [ ! -d bitcoin ]; then
	git clone https://github.com/bitcoin/bitcoin.git || exit $?
fi
cd bitcoin && \
git checkout v${VERSION} && \
cd ../gitian-builder && \
mkdir -p inputs && cd inputs/ || exit $?

## get each dependency
## they are validated afterwards by gbuild
while read -r URL FNAME; do
	if [ -z "$URL" ]; then
		continue
	fi
	echo "wget -q --continue --no-check-certificate '$URL' -O '$FNAME'"
done < ../../input-sources/${VERSION}.txt | parallel -j10 || exit $?

## verify that all sources are correct before continuing
md5sum -c < ../../input-sources/${VERSION}.txt.md5 && \
cd .. && \
./bin/gbuild ../bitcoin/contrib/gitian-descriptors/boost-linux.yml && \
mv build/out/boost-*.zip inputs/ && \
./bin/gbuild ../bitcoin/contrib/gitian-descriptors/deps-linux.yml && \
mv build/out/bitcoin-deps-*.zip inputs/ && \
./bin/gbuild --commit bitcoin=v${VERSION} ../bitcoin/contrib/gitian-descriptors/gitian-linux.yml && \
echo "Completed successfully." && \
echo "The output files are in: gitian-builder/build/out/"
