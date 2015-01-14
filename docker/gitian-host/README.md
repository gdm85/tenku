Gitian host docker container
============================

This image contains a [Dockerfile](http://docs.docker.io/reference/builder/) to generate a [gitian-builder](https://gitian.org/) host image, that can subsequently be used for reproducible builds using LXC VMs.

Hierarchy:
```<your real host (running docker daemon)> -> gitian-host docker container -> <i386/amd64 LXC containers used to perform gbuilds>```

See also https://github.com/devrandom/gitian-builder/issues/53

How to build the image
----------------------
I have not yet pushed images to the [Docker Registry](https://index.docker.io/), but it is a non-issue because you are supposed to create your images from scratch.

First run **scripts/build-wheezy.sh** to get a Debian Wheezy image debootstrapped from Debian repositories.

**NOTE:** you must have debootstrap on your real host to run this script successfully, and also make sure you have a keyring with APT keys, see also https://wiki.debian.org/SecureApt

At this point run **scripts/create-gitian-host.sh**, this will simply build the Dockerfile that installs the few necessary dependencies inside the prepared image.

Afterwards you can spawn a gitian-host container as follows:

```
$ scripts/spawn-gitian-host.sh
You can now SSH into container 8a955ff5607b62d4c295745f27bbc38f2e8e011ea93053e641617d50ad2aa5a2:
ssh -o SendEnv= -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no debian@172.17.0.2
$ 
```

**NOTE:** when I say "run", what I really mean is "read the script, study it for your own learning purposes, then run it" ;)

This will create a privileged container that you can access with the SSH command displayed.

First step
----------

As first step it is reccomended to run the script ./build-base-vms.sh; this will take a while to create the 2 VMs.
Once done, you have prepared a gitian builder environment for deterministic builds. You might want to stop the container and create an image to store away so that in future you can fork from there for new gitian-builder containers.

Derived images
--------------
A [bitcoin gitian host container](../gitian-bitcoin/host/README.md) is available.

Credits
-------
Thanks to jpetazzo for [dind](https://github.com/jpetazzo/dind) and to #docker & bitcoin-dev IRC users for the help&assistance!
