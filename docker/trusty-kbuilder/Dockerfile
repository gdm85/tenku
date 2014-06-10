## trusty-kbuilder
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
ADD sources.list /etc/apt/sources.list

RUN apt-get update && apt-get install -y apt-utils aptitude && aptitude update && aptitude safe-upgrade -y && \
aptitude install -y nano tmux fakeroot build-essential crash kexec-tools makedumpfile kernel-wedge openssh-server

## log rotation is managed outside, thus remove it
## install necessary daemons
RUN apt-get remove -y logrotate

## set current user's id_rsa as only allowed key
ADD authorized_keys /root/.ssh/authorized_keys
RUN chmod -R go-rwx /root/.ssh

## disable password logins & reverse DNS lookups
RUN sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && echo 'UseDNS no' >> /etc/ssh/sshd_config

EXPOSE 22

##NOTE: this will use current kernel version!
RUN apt-get build-dep -y --no-install-recommends linux-image-$(uname -r)
RUN apt-get install -y git-core libncurses5 libncurses5-dev libelf-dev asciidoc binutils-dev

## user that will make the compilation
RUN useradd -m -s /bin/bash rdeckard

## add script for getting source
ADD build-kernel.sh /home/rdeckard/
ADD patches/ /home/rdeckard/patches/

RUN chown -R rdeckard.rdeckard /home/rdeckard

CMD /usr/sbin/sshd -D -e
