#!/bin/bash

usage() {
	echo "* Resize a VM image into 3G" 
	echo " - $0 [IMG-to-mount]"
	echo " - ex) $0 cloud.img"

	exit -1
}

if [ -z $1 ]; then
	usage
fi
IMG_NAME=$1

echo "1. backup"
cp $IMG_NAME $IMG_NAME.bak

echo "2. create new image with increase size"
TMP_DIR=`mktemp -d`
qemu-img create -f qcow2 -o preallocation=metadata /tmp/$IMG_NAME.qcow2 3G
fallocate -l 3221225472 /tmp/$IMG_NAME.qcow2

echo "3. check partitons of original image"
echo "(You need to install libguestfs-tools)"
# existing partition layers
virt-filesystems --long --parts --blkdevs -h -a $IMG_NAME
guestfish --ro -a $IMG_NAME <<EOF
  run
  part-list /dev/sda
EOF

echo "4. resize partitons of original image and create a new vm image"
virt-resize --resize /dev/sda1=+1G $IMG_NAME /tmp/${IMG_NAME}.qcow2

echo "5. move new vm image into $VM_DIR"
mv /tmp/${IMG_NAME}.qcow2 $PWD

echo "6. Done!!! ${IMG_NAME}.qcow2 created"
#chown libvirt-qemu.kvm /vms/herman/herman_vd.qcow2
