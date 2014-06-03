Building bitcoin with a gitian-builder Docker container
=======================================================

This image allows automated gitian builds of bitcoin using a docker container.
Before proceeding make sure you have created the necessary *wheezy* and *gitian-host* images, see [these instructions](../gitian-host/README.md).

Afterwards you can create the image by running [create-gitian-bitcoin-host.sh).
](../scripts/create-gitian-bitcoin-host.sh).

NOTE: this image currently supports only building of bitcoin 0.9.1, but it can be easily adapted to build other versions.
You can submit the source lists for other versions as a patch or pull request.

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

Preparing the gitian environment
--------------------------------

If you have already prepared the base VMs ([/build-base-vms.sh](../gitian-host/build-base-vms.sh)) inside the gitian host container, all what you need to do is:

```sh
ssh -o SendEnv= debian@your-gitian-host ./build-bitcoin.sh 0.9.1
```

Notice the parameter 0.9.1, that is the version we are going to build.

[build-bitcoin.sh](build-bitcoin.sh) is a script that will download & build all the dependencies and then bitcoin itself, for both i386 and amd64 Linux architectures.

**NOTE:** the SendEnv= is there to overcome an [issue](https://github.com/devrandom/gitian-builder/issues/56) in gitian-builder that allows pollution of the LXC environment.

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
