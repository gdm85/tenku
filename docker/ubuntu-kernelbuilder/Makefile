ifeq ($(KERNEL_VERSION),)
	KERNEL_VERSION := $(shell uname -r)
endif

linux-image-%:
	mkdir -p packages
	docker run -e KERNEL_VERSION=$(KERNEL_VERSION) -v $(CURDIR)/packages:/home/rdeckard/packages -v $(CURDIR)/patches:/home/rdeckard/patches:ro $*-kernelbuilder ./build-kernel.sh $(KERNEL_VERSION)

## supports any Ubuntu version (trusty, wily etc)
%:
	TMPD=`mktemp -d` && cp build-kernel.sh "$$TMPD/" && \
	sed -e 's~%IMAGE%~$*~g' -e 's~%KERNEL_VERSION%~$(KERNEL_VERSION)~' Dockerfile.tpl > "$$TMPD/Dockerfile" && cd "$$TMPD" && \
	docker build --tag='$*-kernelbuilder' . && cd && rm -rf "$TMPD"

.DEFAULT: trusty
