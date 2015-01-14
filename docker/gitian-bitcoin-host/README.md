Building bitcoin with a gitian-builder Docker container
=======================================================

This image allows automated Gitian builds of bitcoin core using a Docker container.

Prerequisites
-------------
Before proceeding make sure you have created these necessary images:
* gdm85/wheezy
* gdm85/gitian-host
* gdm85/gitian-host-vms

Instructions to build them are available [here](../gitian-host/README.md).

Image creation
---------------
Afterwards you can create the *gdm85/gitian-bitcoin-host* image by running [scripts/create-gitian-bitcoin-host.sh](../scripts/create-gitian-bitcoin-host.sh).

Bitcoin input sources
---------------------
Since version 0.10.0 it's no more needed to use [input-sources/](input-sources/).

Do not forget to read also the [Preamble here](../gitian-host/README.md#preamble) to correctly use Gitian builder and provided scripts.

Spawning a container
--------------------

A new container for Gitian bitcoin builds can be spawned with:

- [scripts/spawn-gitian-bitcoin-host.sh](scripts/spawn-gitian-bitcoin-host.sh)

This script will spawn a running Docker container and provide details about how to connect via SSH to the container, example:
```
$ scripts/spawn-gitian-bitcoin-host.sh
You can now SSH into container 3bc0d0611374ca4d4730fd5fb1067808b1bcfd072ec7cf029393a7fd99ec856e:
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no debian@172.17.0.3
$ 
```

You can use this specific SSH command line to get a shell in the container and proceed to next steps.

Preparing the gitian environment
--------------------------------

To initiate a gitian build of bitcoin you will run:

- [./build-bitcoin.sh](bin/build-bitcoin.sh) 0.10.0rc1

Notice the parameter 0.10.0, that is the version we are going to build and must be available in [input-sources](input-sources/).

[build-bitcoin.sh](bin/build-bitcoin.sh) is a script that will download & build all the dependencies and then bitcoin itself, for both i386 and amd64 Linux architectures.

Signing
-------

In order to sign the build you can either import your private key in container's debian user gpg, or perform the signing externally.

In this example we will cover the former case; run [~/sign.sh](bin/sign.sh) script and check that your generated assert file (in a subdirectory of ~/gitian.sigs) matches with those of [other developers](https://github.com/bitcoin/gitian.sigs).
**NOTE:** Only the out_manifest signatures do matter, not all the dependencies.

Submitting your signature
-------------------------

If signatures do match, you can fork the [gitian sigs repo](https://github.com/bitcoin/gitian.sigs), add & commit your signatures and submit a pull request for inclusion.
