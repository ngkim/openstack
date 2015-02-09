#!/bin/bash

usage() {
	echo "* Check erros in a VM image" 
	echo " - $0 [IMG-to-check]"
	echo " - ex) $0 cloud.img"

	exit -1
}

IMG=$1
if [ -z $IMG ]; then
	usage
fi

qemu-img check -f qcow2 -r all $IMG
