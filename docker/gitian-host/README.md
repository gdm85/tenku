What is this?
=============

A [Dockerfile](http://docs.docker.io/reference/builder/) to generate a [gitian-builder](https://gitian.org/) host image, that can subsequently be used for reproducible builds using LXC VMs.

It goes like this:
```<your real host> -> docker -> gitian-host container -> <LXC containers to perform gbuilds>```

Yes, it's a bit of an inception.

See also https://github.com/devrandom/gitian-builder/issues/53

How to build the image
----------------------

I have not yet pushed images to the [Docker Registry](https://index.docker.io/), but it is a non-issue because you are supposed to create your images from scratch.

First run **scripts/build-wheezy.sh** to get a Debian Wheezy image debootstrapped from Debian repositories.

**NOTE:** you must have debootstrap on your real host to run this script successfully, and also make sure you have a keyring with APT keys, see also https://wiki.debian.org/SecureApt

At this point run **scripts/create-gitian-host.sh**, if all goes well then you can spawn a gitian-builder container as follows:

```
$ scripts/spawn-gitian-host.sh
You can now SSH into container 8a955ff5607b62d4c295745f27bbc38f2e8e011ea93053e641617d50ad2aa5a2:
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no debian@172.17.0.2
$ 
```

**NOTE:** when I say "run", what I really mean is "read the script, study it for your own learning purposes, then run it" ;)

This will create a privileged container that you can access with the SSH command displayed

Credits
-------

Thanks to jpetazzo for [dind](https://github.com/jpetazzo/dind) and to the vibrant Docker community for the help&assistance!
