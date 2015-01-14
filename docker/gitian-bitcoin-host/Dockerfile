## gitian-bitcoin-host
##
## VERSION 0.1.0
##

FROM gdm85/gitian-host-vms

MAINTAINER Giuseppe Mazzotta "gdm85@users.noreply.github.com"

RUN aptitude install make -y

COPY input-sources/ /home/debian/input-sources/
COPY bin/build-bitcoin.sh /home/debian/
COPY bin/sign.sh /home/debian/

## patch to not attempt removal of build directory (will be a volume)
COPY gitian-gbuild.patch /home/debian/
RUN cd gitian-builder && patch -p1 < ../gitian-gbuild.patch && rm ../gitian-gbuild.patch

## patch to write asserts only (best for detached signatures)
COPY gitian-gasserts.patch /home/debian/
RUN cd gitian-builder && cp bin/gsign bin/gasserts && patch -p1 < ../gitian-gasserts.patch && rm ../gitian-gasserts.patch

WORKDIR /home/debian

RUN mkdir gitian-builder/inputs

RUN chown -R debian.debian input-sources build-bitcoin.sh sign.sh gitian-builder/inputs
