#!/bin/bash

usage() {
	echo "* Convert a VM image into a new VM image" 
	echo " - $0 [IMG-to-convert]"
	echo " - ex) $0 cloud.img"

	exit -1
}

IMG=$1
if [ -z $IMG ]; then
	usage
fi


qemu-img convert $IMG -O qcow2 convert-$IMG
