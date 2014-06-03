
FROM gdm85/gitian-host

MAINTAINER Giuseppe Mazzotta "gdm85@users.noreply.github.com"

RUN apt-get install -y parallel patch

ADD gitian.patch /home/debian/

WORKDIR /home/debian

RUN cd gitian-builder && patch -p1 < ../gitian.patch

ADD build-bitcoin.sh /home/debian/

RUN chown -R debian.debian /home/debian/
