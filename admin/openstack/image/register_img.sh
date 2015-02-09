#!/bin/bash

usage() {
	echo "* Register a VM image to OpenStack" 
	echo " - $0 [IMG-name] [IMG-to-mount]"
	echo " - ex) $0 ubuntu-server-12.04 precise-server-cloudimg-amd64-disk1.img"

	exit -1
}

if [ -z $2 ]; then
	usage
fi

#IMG_NAME=ubuntu-server-13.04
#DISK_IMG=raring-server-cloudimg-amd64-disk1.img

IMG_NAME=$1
DISK_IMG=$2

glance image-create --name $IMG_NAME \
	--is-public true \
	--container-format bare \
	--disk-format qcow2 \
	--file $DISK_IMG
