FROM trusty-pkgbuilder

RUN	apt-get build-dep -y --no-install-recommends linux-image-$(uname -r) && \
	apt-get install -y git-core libncurses5 libncurses5-dev libelf-dev asciidoc binutils-dev ## specific for kernel building

## add script for getting source
COPY build-kernel.sh /home/rdeckard/
