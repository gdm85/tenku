#!/bin/bash

if [ ! $# -eq 3 ]; then
	echo "Usage: sign.sh version signer-id gitian-descriptor.yml" 1>&2
	exit 1
fi

VERSION="$1"
SIGNER="$2"
DESC="$3"

cd gitian-builder && \
./bin/gsign --signer $SIGNER --release ${VERSION} --destination ../gitian.sigs/ "../bitcoin/contrib/gitian-descriptors/$DESC"
