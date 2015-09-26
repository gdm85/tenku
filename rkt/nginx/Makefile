.DEFAULT_GOAL := all
.PHONY := all clean

## all necessary deb packages
DEBS := nginx

all: nginx.aci

nginx.aci:
	deb2aci -pkg $(DEBS) -manifest build.manifest -image $@

clean:
	rm -f nginx.aci
