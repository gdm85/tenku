# lxd-images

Set of images for use with [LXD](https://linuxcontainers.org/lxd/).

<a rel="license" href="http://creativecommons.org/licenses/by-sa/2.0/"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-sa/2.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/2.0/">Creative Commons Attribution-ShareAlike 2.0 Generic License</a>.

## busybox-nonroot

Running the containers' processes as non-root with ``busybox-nonroot`` is useful when you design applications that do not need root privileges,
as you will be able to detect problems that would otherwise be unnoticed when running with root privileges.

Create the image tarball with:
```
make
```

This will import the standard ``busybox`` image if you don't already have it.

Afterwards you can import ``busybox-nonroot`` image with:
```
make import
```

This image has a ``nobody`` user defined, so that you can run all processes inside the container as a non-privileged user.
**NOTE:** this is fundamentally different from root uid/gid mapping (which you should still use, if possible), as explained in [this blog post](https://www.stgraber.org/2014/01/17/lxc-1-0-unprivileged-containers/).
