Building bitcoin with the gitian-builder host image
===================================================

This image currently supports only building of bitcoin 0.9.1, but it can be easily adapted to build other versions.

It is based on https://github.com/bitcoin/bitcoin/blob/0.9.1/doc/release-process.md (and more recent versions).

Preparing the gitian environment
--------------------------------

First, login into the freshly spawned gitian-host container with 'debian' user. If you login via ssh then do not forget to discard environment with:

```sh
ssh -o SendEnv= debian@your-gitian-host
```
This is to overcome an issue in gitian-builder that allows pollution of the LXC environment.

Step 1: base VMs
----------------

Step 1 is a script that allows creation of the base VMs. In your debian home directory, as debian user, run:

```sh
./step1.sh
```

And wait for the creation of i386 and amd64 images.
Once done, you have prepared a gitian builder environment for deterministic bitcoin builds. You might want to stop the container and create an image to store away so that in future you can fork from here for new builds.

Step 2: building dependencies & bitcoin
---------------------------------------

This will build all dependencies:
```sh
./step2.sh
```

(You can also run both step1.sh and step2.sh altogether):
```sh
ssh -o SendEnv= debian@your-gitian-host "step1.sh && step2.sh"
```

Signing
-------

Now you have completed the build of bitcoin and only the signing part is left.
Before doing that, you can inspect that signatures are matching with other developers by peeking inside ~/gitian.sigs

Script to sign the build:
```bash
#!/bin/bash
set -e
export SIGNER=yourSignerName
export VERSION=0.9.1

./bin/gsign --signer $SIGNER --release ${VERSION} --destination ../gitian.sigs/ ../bitcoin/contrib/gitian-descriptors/gitian-linux.yml
```

***NOTE:*** this will fail if you do not have $SIGNER's secret key in `gpg -K`

Submitting your signature
-------------------------

If everything went well, you can fork the [gitian sigs repo](https://github.com/bitcoin/gitian.sigs), commit your signatures and submit a pull request for inclusion.
