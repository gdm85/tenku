#!/bin/bash

set -e

## enter the source-unpacked location
cd build/linux-*

## will fail here if no patches are available
for MYP in $(ls ../../patches); do
	patch -p1 < ../../patches/$MYP
done

fakeroot debian/rules clean

DEB_BUILD_OPTIONS=parallel=4 AUTOBUILD=1 NOEXTRAS=1 fakeroot debian/rules binary-generic

mv ../*.deb $HOME/packages/
