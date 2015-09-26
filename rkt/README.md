rkt images
==========

This repository contains recipes for various [ACI](https://github.com/appc/spec/blob/master/spec/aci.md) images that can be used with [rkt](https://github.com/coreos/rkt).

<a rel="license" href="http://creativecommons.org/licenses/by-sa/2.0/"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-sa/2.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/2.0/">Creative Commons Attribution-ShareAlike 2.0 Generic License</a>.

Building
========

You will need [deb2aci](https://github.com/gdm85/deb2aci) to build these ACI images; you can fetch it automatically into your ``GOPATH`` with:
```
make get-tools
```

To build all images, run:
```
make
```

To build a specific image, for example ``nginx``, run:
```
make -C nginx
```

**DO NOT** run ``make nginx``, it would not build anything.

Each image subdirectory comes with a README.md for specific documentation and instructions.
