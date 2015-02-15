#!/bin/bash

usage() {
	echo "Usage: $0 [DEV_ID] [SRC_NET] [DST_NET]"
	echo " ex) $0 ba14145c-8 192.168.1.0/24 192.168.51.0/24"
	exit 0
}

if [ -z "$3" ]; then
	usage
		
fi

insert_rule() {
	CHAIN_NAME=$1
	SRC_NET=$2
	DST_NET=$3

	iptables -I $CHAIN_NAME 2 -s $SRC_NET -d $DST_NET -p all -j RETURN
}

list_rule() {
	CHAIN_NAME=$1

	iptables -L $CHAIN_NAME -n
}

DEV_ID=$1
SRC_NET=$2
DST_NET=$3

CHAIN_NAME="neutron-openvswi-s${DEV_ID}"

insert_rule $CHAIN_NAME $SRC_NET $DST_NET
list_rule $CHAIN_NAME

