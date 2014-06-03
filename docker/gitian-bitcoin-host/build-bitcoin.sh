#!/bin/bash
set -e

if [[ ! $# -eq 1 ]]; then
	echo "Please specify version" 1>&2
	exit 1
fi

VERSION="$1"

git clone https://github.com/bitcoin/bitcoin.git
cd bitcoin
git checkout v${VERSION}

cd ../gitian-builder
mkdir -p inputs; cd inputs/

## get each dependency
## they are validated afterwards by gbuild
while read -r URL FNAME; do
	if [ -z "$URL" ]; then
		continue
	fi
	wget --no-check-certificate "$URL" -O "$FNAME"
done < ../input-sources/${VERSION}.txt

cd ..
./bin/gbuild ../bitcoin/contrib/gitian-descriptors/boost-linux.yml
mv build/out/boost-*.zip inputs/
./bin/gbuild ../bitcoin/contrib/gitian-descriptors/deps-linux.yml
mv build/out/bitcoin-deps-*.zip inputs/
./bin/gbuild --commit bitcoin=v${VERSION} ../bitcoin/contrib/gitian-descriptors/gitian-linux.yml
