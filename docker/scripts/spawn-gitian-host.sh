#!/bin/bash

set -e

CID=$(docker run -d --privileged gitian-host) || exit $?

echo "You can now SSH into container $CID (IPv4 $IP) with user debian"
