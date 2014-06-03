Building bitcoin with a gitian-builder Docker container
=======================================================

This image allows automated gitian builds of bitcoin 0.9.1 using a docker container.
Before proceeding make sure you have created the necessary *wheezy* and *gitian-host* images, see [these instructions](../gitian-host/README.md).

Afterwards you can create this image by running [this script](../scripts/create-gitian-bitcoin-host.sh).

NOTE: this image currently supports only building of bitcoin 0.9.1, but it can be easily adapted to build other versions.

Preparing the gitian environment
--------------------------------

If you have already prepared the base VMs (./build-base-vms.sh) inside the gitian host container, all what you need to do is:

```sh
ssh -o SendEnv= debian@your-gitian-host ./build-bitcoin.sh
```

[build-bitcoin.sh](build-bitcoin.sh) is a script that will download & build all the dependencies and then bitcoin itself, for both i386 and amd64 Linux architectures.

**NOTE:** the SendEnv= is there to overcome an [issue](https://github.com/devrandom/gitian-builder/issues/56) in gitian-builder that allows pollution of the LXC environment.

Signing
-------

Now you have completed the build of bitcoin and only the signing part is left.
Before doing that, you can verify if signatures are matching with those of [other developers](https://github.com/bitcoin/gitian.sigs) by peeking inside *~/gitian.sigs* of the running container.

In order to sign you have to either put your private key in the container's *~/.gnupg* or perform the signing externally, at your option.

If you have the private key in the container (also displayed by `gpg -K`), then you can use this script:
```bash
#!/bin/bash
set -e
export SIGNER=yourSignerName
export VERSION=0.9.1

cd gitian-builder
./bin/gsign --signer $SIGNER --release ${VERSION} --destination ../gitian.sigs/ ../bitcoin/contrib/gitian-descriptors/gitian-linux.yml
```

Submitting your signature
-------------------------

If everything went well, you can fork the [gitian sigs repo](https://github.com/bitcoin/gitian.sigs), commit your signatures and submit a pull request for inclusion.
