## gitian-bitcoin-host
##
## VERSION 0.1.0
##

FROM gdm85/gitian-host

MAINTAINER Giuseppe Mazzotta "gdm85@users.noreply.github.com"

RUN apt-get install -y patch

ADD gitian.patch /home/debian/

## patch to allow paralle creation of VMs
RUN cd /home/debian/gitian-builder && patch -p1 < ../gitian.patch

ADD input-sources/ /home/debian/input-sources/
ADD build-bitcoin.sh /home/debian/
ADD sign.sh /home/debian/

RUN chown -R debian.debian /home/debian/
