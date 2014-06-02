Building bitcoin with the gitian-builder host image
===================================================

These are instructions to build version 0.9.1 of bitcoin with the [gitian-host](gitian-host/) image.

They are based on https://github.com/bitcoin/bitcoin/blob/0.9.1/doc/release-process.md (and more recent versions).

Preparing the gitian environment
--------------------------------

First, login into the freshly spawned gitian-host container with 'debian' user.

Install a few extra packages:

```
sudo apt-get install -y parallel patch
```

Apply this patch to gitian-builder:

```
diff --git a/bin/make-base-vm b/bin/make-base-vm
index c1920f3..8a44f13 100755
--- a/bin/make-base-vm
+++ b/bin/make-base-vm
@@ -109,16 +109,3 @@ rm -rf $OUT
 sudo vmbuilder kvm ubuntu --rootsize 10240 --arch=$ARCH --suite=$SUITE --addpkg=$addpkg --removepkg=$removepkg --ssh-key=var/id_dsa.pub --ssh-user-key=var/id_dsa.pub --mirror=$MIRROR --secu
 mv $OUT/*.qcow2 $OUT.qcow2
 rm -rf $OUT
-
-if [ $LXC = "1" ]; then
-    #sudo debootstrap --include=$addpkg --arch=$ARCH $SUITE $OUT-root $MIRROR
-    echo Extracting partition for lxc
-    qemu-img convert $OUT.qcow2 $OUT.raw
-    loop=`sudo kpartx -av $OUT.raw|sed -n '/loop.p1/{s/.*loop\(.\)p1.*/\1/;p}'`
-    sudo cp --sparse=always /dev/mapper/loop${loop}p1 $OUT
-    sudo chown $USER $OUT
-    sudo kpartx -d /dev/loop$loop
-    rm -f $OUT.raw
-    # bootstrap-fixup is done in libexec/make-clean-vm
-fi
-

```

Afterwards run this script:

```
#!/bin/bash
set -e

source ~/.bash_profile

export VERSION=0.9.1
git clone https://github.com/bitcoin/bitcoin.git
cd bitcoin
git checkout v${VERSION}
cd ../gitian-builder
mkdir -p var
if [ ! -e var/id_dsa ]; then
  ssh-keygen -t dsa -f var/id_dsa -N ""
fi

export MIRROR_HOST=$GITIAN_HOST_IP
SUITE=precise

echo -e "MIRROR_HOST=$GITIAN_HOST_IP bin/make-base-vm --lxc --arch i386 --suite $SUITE\nMIRROR_HOST=$GITIAN_HOST_IP bin/make-base-vm --lxc --arch amd64 --suite $SUITE" | parallel -j2 || exit $?

function ext_partition() {
	local OUT=$1
	echo Extracting $OUT partition for lxc
	qemu-img convert $OUT.qcow2 $OUT.raw
 	loop=`sudo kpartx -av $OUT.raw|sed -n '/loop.p1/{s/.*loop\(.\)p1.*/\1/;p}'`
	sudo cp --sparse=always /dev/mapper/loop${loop}p1 $OUT
	sudo chown $USER $OUT
	sudo sync
	sleep 5
	sudo kpartx -d /dev/loop$loop
	sudo rm /dev/mapper/loop${loop}p1
	rm -f $OUT.raw
}

ext_partition base-${SUITE}-i386 && \
ext_partition base-${SUITE}-amd64 || exit $?

```

At this point you have prepared a gitian builder environment for deterministic bitcoin builds. You might want to stop the container and create an image to store away so that in future you can fork from here for new builds.

Building bitcoin
----------------

Let's continue with another script

```
#!/bin/bash
set -e

export VERSION=0.9.1

cd gitian-builder
mkdir -p inputs; cd inputs/
wget 'http://miniupnp.free.fr/files/download.php?file=miniupnpc-1.8.tar.gz' -O miniupnpc-1.8.tar.gz
wget --no-check-certificate 'https://www.openssl.org/source/openssl-1.0.1g.tar.gz'
wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
wget 'http://zlib.net/zlib-1.2.8.tar.gz'
wget 'ftp://ftp.simplesystems.org/pub/png/src/history/libpng16/libpng-1.6.8.tar.gz'
wget 'https://fukuchi.org/works/qrencode/qrencode-3.4.3.tar.bz2'
wget 'https://downloads.sourceforge.net/project/boost/boost/1.55.0/boost_1_55_0.tar.bz2'
wget 'https://download.qt-project.org/official_releases/qt/5.2/5.2.0/single/qt-everywhere-opensource-src-5.2.0.tar.gz'
wget 'https://protobuf.googlecode.com/files/protobuf-2.5.0.tar.bz2'
cd ..
./bin/gbuild ../bitcoin/contrib/gitian-descriptors/boost-linux.yml
mv build/out/boost-*.zip inputs/
./bin/gbuild ../bitcoin/contrib/gitian-descriptors/deps-linux.yml
mv build/out/bitcoin-deps-*.zip inputs/
./bin/gbuild --commit bitcoin=v${VERSION} ../bitcoin/contrib/gitian-descriptors/gitian-linux.yml
```

Now you have completed the build of bitcoin and only the signing part is left.
Before doing that, you can inspect that signatures are matching with other developers by peeking inside ~/gitian.sigs

Script to sign the build:
```
#!/bin/bash
set -e
export SIGNER=yourSignerName
export VERSION=0.9.1

./bin/gsign --signer $SIGNER --release ${VERSION} --destination ../gitian.sigs/ ../bitcoin/contrib/gitian-descriptors/gitian-linux.yml
```

***NOTE:*** this will fail if you do not have $SIGNER's secret key in `gpg -K`

Signatures mismatch
-------------------

The signatures currently do not match due to some issues yet to be determined (most probably filesystem related).

Submitting your signature
-------------------------

If everything went well, you can fork the [gitian sigs repo](https://github.com/gdm85/gitian.sigs), commit your signatures and submit a pull request for inclusion.
