#!/bin/bash

BASENAME=$(dirname $(readlink -m $0))

cd $BASENAME/../trusty-kbuilder || exit $?

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

##NOTE: can leave behind a running container of gitian-host
docker build --tag=gdm85/trusty-kbuilder . && \
echo "Ubuntu Trusty kernel builder image created successfully!" && \
echo "You can now spawn containers with:" && \
echo "docker run -d gdm85/trusty-kbuilder"
