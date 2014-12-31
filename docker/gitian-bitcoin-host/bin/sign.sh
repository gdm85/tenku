#!/bin/bash

if [[ ! $# -eq 2 ]]; then
	echo "Please specify version and signer id" 1>&2
	exit 1
fi

VERSION="$1"
SIGNER="$2"

cd gitian-builder && \
./bin/gsign --signer $SIGNER --release ${VERSION} --destination ../gitian.sigs/ ../bitcoin/contrib/gitian-descriptors/gitian-linux.yml
