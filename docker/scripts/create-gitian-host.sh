#!/bin/bash

BASENAME=$(dirname $(readlink -m $0))

cd $BASENAME/../gitian-host || exit $?

if [ ! -f authorized_keys ]; then
	echo "No authorized_keys file found in $PWD"
	if [ -f ~/.ssh/id_rsa.pub ]; then
		echo "Do you want to use ~/.ssh/id_rsa.pub? (y/n)"
		read -r ANSWER
		if [[ "$ANSWER" == "y" ]]; then
			cp -v ~/.ssh/id_rsa.pub authorized_keys || exit $?
		else
			exit 1
		fi
	else
		exit 1
	fi
fi

docker build --tag=gdm85/gitian-host . && \
echo "Gitian host image created successfully!" && \
echo "You can now spawn containers with spawn-gitian-host.sh"
