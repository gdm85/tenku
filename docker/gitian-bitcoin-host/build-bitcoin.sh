#!/bin/bash

if [[ ! $# -eq 1 ]]; then
	echo "Please specify version" 1>&2
	exit 1
fi

VERSION="$1"

if [ ! -d bitcoin ]; then
	git clone https://github.com/bitcoin/bitcoin.git || exit $?
fi
cd bitcoin && \
git checkout v${VERSION} || exit $?

cd ../gitian-builder && \
mkdir -p inputs && cd inputs/ || exit $?

## get each dependency
## they are validated afterwards by gbuild
while read -r URL FNAME; do
	if [ -z "$URL" ]; then
		continue
	fi
	wget --continue --no-check-certificate "$URL" -O "$FNAME" || exit $?
done < ../../input-sources/${VERSION}.txt || exit $?

## verify that all sources are correct before continuing
md5sum -c < ../../input-sources/${VERSION}.txt.md5 || exit $?

cd ..
./bin/gbuild ../bitcoin/contrib/gitian-descriptors/boost-linux.yml || exit $?
mv build/out/boost-*.zip inputs/
./bin/gbuild ../bitcoin/contrib/gitian-descriptors/deps-linux.yml || exit $?
mv build/out/bitcoin-deps-*.zip inputs/
./bin/gbuild --commit bitcoin=v${VERSION} ../bitcoin/contrib/gitian-descriptors/gitian-linux.yml || exit $?
echo "Completed successfully."
echo "The output files are in: gitian-builder/build/out/"
