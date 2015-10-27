.DEFAULT: trusty

## supports any base Ubuntu image (gdm85/trusty, gdm85/wily etc)
## they should be generated with make-ubuntu-image.sh
%:
	TMPD=`mktemp -d` && sed 's~%IMAGE%~gdm85/$@~g' Dockerfile.tpl > "$$TMPD/Dockerfile" && sed 's~%DIST%~$@~g' sources.list.tpl > "$$TMPD/sources.list" && cd "$$TMPD" && \
	docker build --tag='$@-pkgbuilder' . && cd && rm -rf "$TMPD"
