#!/bin/bash
set -e

if [[ -z "$VERSION" ]]; then
	echo "Please define VERSION environment variable for bitcoin checkout" 1>&2
	exit 1
fi

if [[ "$VERSION" != "0.9.1" ]]; then
	echo "Dependencies on this script are valid only for 0.9.1"
	exit 2
fi

cd gitian-builder
mkdir -p inputs; cd inputs/

##
## dependencies valid only for 0.9.1!
##
wget 'http://miniupnp.free.fr/files/download.php?file=miniupnpc-1.8.tar.gz' -O miniupnpc-1.8.tar.gz
wget --no-check-certificate 'https://www.openssl.org/source/openssl-1.0.1g.tar.gz'
wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
wget 'http://zlib.net/zlib-1.2.8.tar.gz'
wget 'ftp://ftp.simplesystems.org/pub/png/src/history/libpng16/libpng-1.6.8.tar.gz'
wget 'https://fukuchi.org/works/qrencode/qrencode-3.4.3.tar.bz2'
wget 'https://downloads.sourceforge.net/project/boost/boost/1.55.0/boost_1_55_0.tar.bz2'
wget 'https://download.qt-project.org/official_releases/qt/5.2/5.2.0/single/qt-everywhere-opensource-src-5.2.0.tar.gz'
wget 'https://protobuf.googlecode.com/files/protobuf-2.5.0.tar.bz2'
cd ..
./bin/gbuild ../bitcoin/contrib/gitian-descriptors/boost-linux.yml
mv build/out/boost-*.zip inputs/
./bin/gbuild ../bitcoin/contrib/gitian-descriptors/deps-linux.yml
mv build/out/bitcoin-deps-*.zip inputs/
./bin/gbuild --commit bitcoin=v${VERSION} ../bitcoin/contrib/gitian-descriptors/gitian-linux.yml
