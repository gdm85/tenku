#!/bin/bash

set -e

apt-get source linux-image-$(uname -r)

cd linux-3.13.0

## will fail here if no patches are available
## why are you recompiling kernel if no custom patches are there?
for MYP in $(ls ../patches); do
	patch -p1 < ../patches/$MYP
done

fakeroot debian/rules clean
DEB_BUILD_OPTIONS=parallel=3 AUTOBUILD=1 NOEXTRAS=1 fakeroot debian/rules binary-generic
