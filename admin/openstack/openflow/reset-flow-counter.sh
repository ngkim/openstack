#!/bin/bash

usage() {
    echo " >> Description : 입력된 open vswitch bridge에 대해서 [ovs-bridge].dump파일의 내용으로 flow들을 replace하여 packet counter를 리셋"
	echo "    -  Usage    : $0 [ovs-bridge]"
	echo "    -  Example  : $0 br-int"
	exit 0
}

if [ -z $1 ]; then
	usage
fi

BR=$1
DIR_DUMP=dump

DUMP=$DIR_DUMP/$BR.dump

if [ -e $DUMP ]; then 
	ovs-ofctl replace-flows --readd $BR $DUMP
else
	echo "$DUMP does not exist"
fi
