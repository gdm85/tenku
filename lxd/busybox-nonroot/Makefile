.DEFAULT := all
.PHONY := all import have-busybox

## current hash of busybox image
BASEIMG := 6e9df9219c50317368ec1e2b37da8bb1f5edcbefae3bae4bd38f41b56a365d09 

all: busybox-nonroot.tar.xz

have-busybox:
	lxc image info busybox >/dev/null || lxd-images import busybox --alias busybox

busybox-nonroot.tar.xz: have-busybox
	TMPD=`mktemp -d` && mkdir -p "$$TMPD/rootfs/etc" && \
	cp overlay/etc/passwd overlay/etc/group "$$TMPD/rootfs/etc/" && cd "$$TMPD" && tar xf /var/lib/lxd/images/$(BASEIMG) && \
	tar pcfJ $(CURDIR)/$@ rootfs/ metadata.yaml && cd && rm -rf "$$TMPD"

import:
	lxc image info busybox-nonroot >/dev/null 2>/dev/null || lxc image import busybox-nonroot.tar.xz --alias busybox-nonroot
