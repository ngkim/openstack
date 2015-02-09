#!/bin/bash

usage() {
    echo " >> Description : 입력된 open vswitch bridge에 대해서 dump-flows 명령을 수행"
	echo "    -  Usage    : $0 [ovs-bridge]"
	echo "    -  Example  : $0 br-int"
	exit 0
}

if [ -z $1 ]; then
	usage
fi

BR=$1

ovs-ofctl dump-flows $BR
