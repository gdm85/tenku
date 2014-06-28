Building bitcoin with a gitian-builder Docker container
=======================================================

This image allows automated gitian builds of bitcoin using a docker container.
Before proceeding make sure you have created the necessary *gdm85/wheezy*, *gdm85/gitian-host* and *gdm85/gitian-host-vms* images, see [these instructions](../gitian-host/README.md).

Afterwards you can create the *gdm85/gitian-bitcoin-host* image by running [scripts/create-gitian-bitcoin-host.sh](../scripts/create-gitian-bitcoin-host.sh).

**NOTE:** this image currently supports only building of bitcoin 0.9.1, but it can be easily adapted to build other versions.
You can submit the source lists for other versions as a patch or pull request, see directory [input-sources/](input-sources/) for currently available versions.

Do not forget to read also the [Preamble here](../gitian-host/README.md#preamble) to correctly use Gitian builder and these provided scripts.

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

To initiate a gitian build of bitcoin you will run:

- [./build-bitcoin.sh](build-bitcoin.sh) 0.9.1

Notice the parameter 0.9.1, that is the version we are going to build and must be available in [input-sources](input-sources/).

[build-bitcoin.sh](build-bitcoin.sh) is a script that will download & build all the dependencies and then bitcoin itself, for both i386 and amd64 Linux architectures.

Signing
-------

Once you have completed the build of bitcoin, you will be ready to perform the signing; before doing that you should verify that signatures are matching with those of [other developers](https://github.com/bitcoin/gitian.sigs) by peeking inside *~/gitian.sigs* of the running container.
Only the out_manifest signatures do matter for this purpose.

In order to sign you have to either put your private key in the container's *~/.gnupg* or perform the signing externally, at your option.

If you have the private key in the container (also displayed by `gpg -K`), then you can use the [sign.sh](sign.sh) script that is already provided, otherwise
run it (with failure) and then copy the *~/gitian.sigs* directory to another machine to apply the GPG signature.

Submitting your signature
-------------------------

If everything went well, you can fork the [gitian sigs repo](https://github.com/bitcoin/gitian.sigs), commit your signatures and submit a pull request for inclusion.
