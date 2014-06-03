#!/bin/bash

set -e

BASENAME=$(dirname $(readlink -m $0))

cd $BASENAME/../gitian-bitcoin-host && \
docker build --tag=gdm85/gitian-bitcoin-host .
