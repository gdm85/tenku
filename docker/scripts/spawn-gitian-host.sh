#!/bin/bash

set -e

CID=$(docker run -d --privileged gdm85/gitian-host) || exit $?
IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CID) || exit $?

echo "You can now SSH into container $CID:"
echo "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no debian@$IP"
