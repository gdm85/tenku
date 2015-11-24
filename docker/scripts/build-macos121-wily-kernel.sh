#!/bin/bash
## build-macos121-wily-kernel.sh
##
## @author gdm85
##
## Build a kernel with fixed bluetooth support for Mac OS 12,1 and Ubuntu Wily
## Based on instructions read from http://www.spinics.net/lists/linux-bluetooth/msg64123.html
##
#

SCRIPTS=$(dirname $(readlink -m $0)) || exit $?

set -e

cd "$SCRIPTS"

if ! docker inspect gdm85/wily >/dev/null 2>/dev/null; then
	./build-ubuntu-image.sh wily
fi

cd ../ubuntu-pkgbuilder

make wily

cd ../ubuntu-kernelbuilder

make wily linux-image-wily

echo "Linux kernel .deb packages are now available in packages/"
