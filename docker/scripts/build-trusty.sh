#!/bin/bash
## @author gdm85
##
## build a base Ubuntu Trusty
#

BASENAME=$(dirname $(readlink -m $0))

## the distro we are going to use
## the distro we are going to use
DISTNAME=trusty
REPOSRC=http://archive.ubuntu.com/ubuntu/

if [ ! $UID -eq 0 ]; then
	echo "This script can only be run as root" 1>&2
	exit 1
fi

## check for prerequisites
if ! type -P debootstrap >/dev/null; then
	echo "You need to install debootstrap" 1&2
	exit 2
fi

## check about the Ubuntu archive keyring
DEFK=/usr/share/keyrings/ubuntu-archive-keyring.gpg
KEYRING=$BASENAME/../keyrings/ubuntu-archive-keyring.gpg
if [ -s $DEFK ]; then
	if ! diff $DEFK $KEYRING; then
		ANSWER=
		while [[ "$ANSWER" != "Y" && "$ANSWER" != "n" ]]; do
			echo -n "The Ubuntu Archive keyring in your system ($DEFK) that will be used to debootstrap is different from the reference provided keyring. Continue? (Y/n) "
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
		echo -n "Your system comes with no Ubuntu Archive keyring in $DEFK that is necessary for debootstrap. Use reference provided keyring? (Y/n) "
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

debootstrap --keyring=$KEYRING $DISTNAME $DISTNAME $REPOSRC && \
cd $DISTNAME && \
tar -c . | docker import - gdm85/$DISTNAME
RV=$?

# always perform cleanup
rm -rf $TMPDIR

exit $RV
