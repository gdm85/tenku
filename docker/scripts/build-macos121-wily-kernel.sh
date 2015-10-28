#!/bin/bash
## build-macos121-wily-kernel.sh
##
## @author gdm85
##
## Build a kernel with fixed bluetooth support for Mac OS 12,1 and Ubuntu Wily
##
#

SCRIPTS=$(dirname $(readlink -m $0)) || exit $?

set -e

cd "$SCRIPTS"

#./build-ubuntu-image.sh wily

cd ../ubuntu-pkgbuilder

make wily

cd ../ubuntu-kernelbuilder

cat<<EOF > patches/macos-121-btusb-fix.patch
--- a/drivers/bluetooth/btusb.c 2015-10-28 14:52:20.466644715 +0000
+++ b/drivers/bluetooth/btusb.c 2015-10-28 14:52:34.715107143 +0000
@@ -2657,7 +2657,7 @@
        BT_DBG("intf %p id %p", intf, id);
 
        /* interface numbers are hardcoded in the spec */
-       if (intf->cur_altsetting->desc.bInterfaceNumber != 0)
+       if (intf->cur_altsetting->desc.bInterfaceNumber != 1)
                return -ENODEV;
 
        if (!id->driver_info) {
@@ -2827,7 +2827,7 @@
                data->isoc = NULL;
        } else {
                /* Interface numbers are hardcoded in the specification */
-               data->isoc = usb_ifnum_to_if(data->udev, 1);
+               data->isoc = usb_ifnum_to_if(data->udev, 3);
        }
 
        if (!reset)
EOF

make wily linux-image-wily

echo "Linux kernel .deb packages are now available in packages/"
