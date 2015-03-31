## trusty-pkgbuilder
##
## VERSION 0.1.0
##
## Trusty image to build kernel
##
#

## NOTE: this image must be debootstrapped with build-trusty.sh
FROM gdm85/trusty

MAINTAINER Giuseppe Mazzotta "gdm85@users.noreply.github.com"

ENV DEBIAN_FRONTEND noninteractive

## replace sources
COPY sources.list /etc/apt/sources.list

RUN	apt-get update && apt-get install -y apt-utils aptitude && aptitude update && aptitude safe-upgrade -y && \
	aptitude install -y nano tmux fakeroot build-essential crash kexec-tools makedumpfile kernel-wedge

## log rotation is not managed in this container, thus remove it
RUN apt-get remove -y logrotate

## user that will make the compilation
RUN useradd -m -s /bin/bash rdeckard && mkdir /home/rdeckard/patches && chown rdeckard.rdeckard /home/rdeckard/patches
