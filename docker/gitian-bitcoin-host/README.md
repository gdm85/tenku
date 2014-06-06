Building bitcoin with a gitian-builder Docker container
=======================================================

This image allows automated gitian builds of bitcoin using a docker container.
Before proceeding make sure you have created the necessary *wheezy* and *gitian-host* images, see [these instructions](../gitian-host/README.md) for the creation of both.

Afterwards you can create the *gitian-bitcoin-host* image by running [scripts/create-gitian-bitcoin-host.sh](../scripts/create-gitian-bitcoin-host.sh).

NOTE: this image currently supports only building of bitcoin 0.9.1, but it can be easily adapted to build other versions.
You can submit the source lists for other versions as a patch or pull request, see directory [input-sources/](input-sources/) for currently available versions.

Preamble
--------

It is **necessary** that before you using these scripts you read them and understand what they do.
Why? Because your goal is to create a gitian build (deterministic) that has not been tampered with.

See also:
- https://gitian.org/
- https://en.wikipedia.org/wiki/Web_of_trust
- http://www.dwheeler.com/trusting-trust/
- https://www.debian.org/
- https://www.docker.io/
- http://www.ubuntu.com/

Spawning a container
--------------------

You can spawn a new container for Gitian bitcoin builds with:

- [scripts/spawn-gitian-bitcoin-host.sh](scripts/spawn-gitian-bitcoin-host.sh)

This script will create the running docker container and provide details about how to connect via SSH to the container, example:
```
$ scripts/spawn-gitian-bitcoin-host.sh
You can now SSH into container 3bc0d0611374ca4d4730fd5fb1067808b1bcfd072ec7cf029393a7fd99ec856e:
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no debian@172.17.0.3
$ 
```

You can use this specific SSH command line to get a shell in the container and proceed to next steps.

Preparing the gitian environment
--------------------------------

First prepare the base VMs inside the gitian host container by running:

- [./build-base-vms.sh](../gitian-host/build-base-vms.sh)

This operation will take a while; afterwards you can proceed to building bitcoin with:

- [./build-bitcoin.sh](build-bitcoin.sh) 0.9.1

Notice the parameter 0.9.1, that is the version we are going to build.

[build-bitcoin.sh](build-bitcoin.sh) is a script that will download & build all the dependencies and then bitcoin itself, for both i386 and amd64 Linux architectures.

Signing
-------

Now you have completed the build of bitcoin and only the signing part is left.
Before doing that, you can verify if signatures are matching with those of [other developers](https://github.com/bitcoin/gitian.sigs) by peeking inside *~/gitian.sigs* of the running container.

In order to sign you have to either put your private key in the container's *~/.gnupg* or perform the signing externally, at your option.

If you have the private key in the container (also displayed by `gpg -K`), then you can use the [sign.sh](sign.sh) script that is already in the running container, otherwise
run it (with failure) and then copy the *~/gitian.sigs~ directory to another machine to apply the GPG signature.

Submitting your signature
-------------------------

If everything went well, you can fork the [gitian sigs repo](https://github.com/bitcoin/gitian.sigs), commit your signatures and submit a pull request for inclusion.
