## gitian-host
##
## VERSION 0.1.0
##
## gitian host privileged container
## see also https://github.com/gdm85/tenku/tree/master/docker/gitian-builder-host.md
##
#

## this image must be debootstrapped with build-wheezy.sh
FROM wheezy

MAINTAINER Giuseppe Mazzotta "gdm85@users.noreply.github.com"

ENV     TERM xterm
ENV     DEBIAN_FRONTEND noninteractive

## some core packages
RUN apt-get update && apt-get install -y htop tmux less locales openssh-server

## these 2 files can be customized
ADD etc/timezone /etc/timezone
ADD etc/locale.gen /etc/locale.gen
RUN dpkg-reconfigure locales && dpkg-reconfigure tzdata

## continue installation of gitian-builder packages
RUN echo "deb http://http.debian.net/debian wheezy main contrib non-free" > /etc/apt/sources.list.d/non-free.list
RUN apt-get install -y iptables ca-certificates sudo bridge-utils git python-cheetah qemu-utils parted kpartx ruby apt-cacher-ng lxc

## disable password logins, reverse DNS lookups & privilege separation (due to chroot issues on latest docker)
RUN sed -i -e 's/^#PasswordAuthentication yes/PasswordAuthentication no/' -e 's/^UsePrivilegeSeparation.*$/UsePrivilegeSeparation no/' /etc/ssh/sshd_config && echo 'UseDNS no' >> /etc/ssh/sshd_config

EXPOSE 22

# this version of Debian needs to run as root, so make sure
# that the build script can exectute it without providing a password
RUN echo "%sudo ALL=NOPASSWD: /usr/bin/lxc-start" > /etc/sudoers.d/gitian-lxc
RUN echo 'debian ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/debian-sudo

RUN useradd -m -s /bin/bash debian && adduser debian sudo

## provide authorized keys to allow connections inside host
ADD authorized_keys /home/debian/.ssh/authorized_keys
RUN chmod -R go-rwx /home/debian/.ssh

WORKDIR /home/debian

## download in clear HTTP & check md5 right afterwards
RUN wget http://archive.ubuntu.com/ubuntu/pool/universe/v/vm-builder/vm-builder_0.12.4+bzr489.orig.tar.gz && echo "ec12e0070a007989561bfee5862c89a32c301992dd2771c4d5078ef1b3014f03  vm-builder_0.12.4+bzr489.orig.tar.gz" | sha256sum -c
RUN tar -zxvf vm-builder_0.12.4+bzr489.orig.tar.gz && cd vm-builder-0.12.4+bzr489 && python setup.py install

## these must always be loaded when you login as 'debian' user
RUN echo 'export USE_LXC=1' >> .bash_profile
RUN echo 'export GITIAN_HOST_IP=10.0.3.2' >> .bash_profile
RUN echo 'export LXC_GUEST_IP=10.0.3.5' >> .bash_profile

RUN git clone https://github.com/devrandom/gitian-builder.git --depth=1
RUN chown -R debian.debian . && chown -R apt-cacher-ng.apt-cacher-ng /var/cache/apt-cacher-ng/

## suggested: run this image with mounted volumes for pre-downloaded inputs and apt-cacher-ng cache
## -v inputs:/home/debian/gitian-builder/inputs -v apt-cacher-ng:/var/cache/apt-cacher-ng
##NOTE: if you do use them, then not forget to set proper user rights for these mounted volumes

## all necessary setup instructions (SSH, LXC)
ADD setup.sh /usr/local/bin/setup.sh

## on run failure, check logs to see if setup failed. on success connect via SSH
CMD /usr/local/bin/setup.sh && /etc/init.d/apt-cacher-ng start && /usr/sbin/sshd -D -e
