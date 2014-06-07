#!/bin/bash
## @author gdm85
##
## build a base Debian Wheezy
#

BASENAME=$(dirname $(readlink -m $0))

## the distro we are going to use
DISTNAME=wheezy
DEBIAN_REPO=http://ftp.debian.org/debian

if [ ! $UID -eq 0 ]; then
	echo "This script can only be run as root" 1>&2
	exit 1
fi

## install prerequisites
## NOTE: may fail on non-Ubuntu/Debian systems
if ! type -P debootstrap >/dev/null; then
        apt-get install debootstrap -y || exit $?
fi

## check about the Debian archive keyring
DEFK=/usr/share/keyrings/debian-archive-keyring.gpg
KEYRING=$BASENAME/../keyrings/debian-archive-keyring.gpg
if [ -s $DEFK ]; then
	if ! diff $DEFK $KEYRING; then
		ANSWER=
		while [[ "$ANSWER" != "Y" && "$ANSWER" != "n" ]]; do
			echo -n "The Debian Archive keyring in your system ($DEFK) that will be used to debootstrap is different from the reference provided keyring. Continue? (Y/n) "
			read -r ANSWER || exit $?
		done
		if [[ "$ANSWER" == "n" ]]; then
			exit 1
		fi
		## use system's keyring, even if different than provided one
		## this is a no-issue only in case the system's keyring is more recent than the provided one
		KEYRING=$DEFK
	fi
else
	ANSWER=
	while [[ "$ANSWER" != "Y" && "$ANSWER" != "n" ]]; do
		echo -n "Your system comes with no Debian Archive keyring in $DEFK that is necessary for debootstrap. Use reference provided keyring? (Y/n) "
		read -r ANSWER || exit $?
	done
	if [[ "$ANSWER" == "n" ]]; then
		exit 1
	fi
fi

echo "Will use $KEYRING"
exit 0

## NOTE: a temporary directory under /tmp is not used because can't be mounted dev/exec
mkdir $DISTNAME || exit $?
TMPDIR=$PWD/$DISTNAME

debootstrap --keyring=$KEYRING $DISTNAME $DISTNAME $DEBIAN_REPO && \
cd $DISTNAME && \
tar -c . | docker import - gdm85/$DISTNAME
RV=$?

# always perform cleanup
rm -rf $TMPDIR

exit $RV
