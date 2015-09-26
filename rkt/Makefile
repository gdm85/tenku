## define here all recursively buildable targets
SUBDIRS := nginx

.PHONY := $(SUBDIRS) recurse clean get-tools
.DEFAULT_GOAL := recurse

RECURSE_TARGET ?= $(MAKECMDGOALS)

recurse:
	@for D in $(SUBDIRS) ; do \
	   if [ -e $${D}/Makefile ]; then \
		$(MAKE) -C "$${D}" $(RECURSE_TARGET) || exit $$? ; \
	   fi ; \
	done

clean: ; @$(MAKE) RECURSE_TARGET=clean recurse

## disable entering/exiting messages
#.SILENT:

get-tools:
	go get github.com/gdm85/deb2aci
