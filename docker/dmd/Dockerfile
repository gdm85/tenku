## dmd
##
## VERSION 2.072
##
## a minimal image installing the official .deb for dmd
## the official image would instead compile and install too many dependencies
##
#

## this image must be debootstrapped with build-wheezy.sh
FROM gdm85/wheezy

## install deps
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update -y && apt-get install libc6-dev gcc libcurl3 -y

## install dmd+dub
RUN export DEBIAN_FRONTEND=noninteractive && cd /tmp && wget --quiet http://downloads.dlang.org/releases/2.x/2.072.0/dmd_2.072.0-0_amd64.deb && \
echo 'cd61bc9d5e511db5d35b3e1410c21f0d38941e038e06c6db2db18e73177efbae  dmd_2.072.0-0_amd64.deb' | sha256sum -c && dpkg -i dmd_2.072.0-0_amd64.deb && rm dmd_2.072.0-0_amd64.deb
