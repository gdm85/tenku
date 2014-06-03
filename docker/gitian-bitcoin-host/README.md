Building bitcoin with the gitian-builder host image
===================================================

This image currently supports only building of bitcoin 0.9.1, but it can be easily adapted to build other versions.

It is based on https://github.com/bitcoin/bitcoin/blob/0.9.1/doc/release-process.md (and more recent versions).

Before proceeding make sure you have created the necessary gdm85/wheezy and gdm85/gitian-host images, see [these instructions](../gitian-host/README.md).

Afterwards you can create this image by running scripts/create-gitian-bitcoin-host.sh.

Preparing the gitian environment
--------------------------------

If you have already prepared the base VMs inside the gitian host container, all what you need to do is:

```sh
ssh -o SendEnv= debian@your-gitian-host ./build-bitcoin.sh
```

That is a script that will build dependencies and bitcoin for both i386 and amd64 Linux architectures.

**NOTE:** the SendEnv= is there to overcome an issue in gitian-builder that allows pollution of the LXC environment.

Signing
-------

Now you have completed the build of bitcoin and only the signing part is left.
Before doing that, you can inspect that signatures are matching with other developers by peeking inside ~/gitian.sigs of the running container.

In order to sign you have to either put your private key in the container's ~/.gnupg or perform the signing externally, at your option.
If you have the private key in the container (so displayed by `gpg -K`), then you can use this script:
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
