#!/bin/bash

source "$MNG_ROOT/include/print.sh"

MNT_DIR=/mnt/ubuntu

usage() {
	echo "* Mount a VM image to $MNT_DIR" 
	echo " - $0 [IMG-to-mount]"
	echo " - ex) $0 cloud.img"

	exit -1
}

VM_IMG=$1
if [ -z $VM_IMG ]; then
	usage
fi

print_info "VM-IMAGE" "Load nbd module"
modprobe nbd max_part=8

print_info "VM-IMAGE" "Run qemu-nbd..."
qemu-nbd -c /dev/nbd0 $VM_IMG

mkdir -p $MNT_DIR
print_info "VM-IMAGE" "Mount $MNT_DIR"
mount /dev/nbd0p1 $MNT_DIR

print_err "VM-IMAGE" "You should run 'chroot $MNT_DIR'"
