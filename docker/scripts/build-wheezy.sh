#!/bin/bash
## @author gdm85
## original article: http://learndocker.com/how-to-build-a-debian-wheezy-base-container/
##
## build a base Debian Wheezy
#

## the distro we are going to use
DISTNAME=wheezy
DEBIAN_REPO=http://ftp.debian.org/debian

if [ ! $UID -eq 0 ]; then
	echo "This script can only be run as root" 1>&2
	exit
fi

## install prerequisites
## NOTE: may fail on non-Ubuntu/Debian systems
if ! type -P debootstrap; then
        apt-get install debootstrap -y || exit $?
fi

## NOTE: a temporary directory under /tmp is not used because can't be mounted dev/exec
mkdir $DISTNAME || exit $?
TMPDIR=$PWD/$DISTNAME

debootstrap $DISTNAME $DISTNAME $DEBIAN_REPO && \
cd $DISTNAME && \
tar -c . | docker import - $DISTNAME
RV=$?

# always perform cleanup
rm -rf $TMPDIR

exit $RV
