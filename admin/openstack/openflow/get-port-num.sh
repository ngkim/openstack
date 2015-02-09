#!/bin/bash

usage() {
    echo " >> Description : 입력된 인터페이스가 주어진 openflow datapath의 몇 번 포트인지를 알려줌"
	echo "    -  Usage    : $0 [ovs-bridge] [interface]"
	echo "    -  Example  : $0 br-int qvo6b8048a9-0e"
	exit 0
}

if [ -z $2 ]; then
	usage
fi

BR=$1
INTF=$2

ovs-ofctl show $BR | grep $INTF | sed 's/(/ /' | sed 's/)/ /' | awk '{print $1}'