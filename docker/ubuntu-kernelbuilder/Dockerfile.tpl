FROM %IMAGE%-pkgbuilder

ENV KERNEL_VERSION %KERNEL_VERSION%

RUN	apt-get build-dep -y --no-install-recommends linux-image-$KERNEL_VERSION && \
	apt-get install -y git-core libncurses5 libncurses5-dev libelf-dev asciidoc binutils-dev

USER rdeckard

## fetch source
RUN mkdir build && cd build && apt-get source linux-image-$KERNEL_VERSION

## add build script
COPY build-kernel.sh /home/rdeckard/
