## ubuntu-pkgbuilder
##
## VERSION 0.1.1
##
## Ubuntu image to build a .deb package
##
#

FROM %IMAGE%

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

WORKDIR /home/rdeckard
