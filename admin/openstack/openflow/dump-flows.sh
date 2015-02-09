#!/bin/bash

usage() {
    echo " >> Description : 입력된 open vswitch bridge에 대해서 dump-flows 명령을 수행 후 [ovs-bridge].dump파일에 이를 dump"
	echo "    -  Usage    : $0 [ovs-bridge]"
	echo "    -  Example  : $0 br-int"
	exit 0
}

if [ -z $1 ]; then
	usage
fi

BR=$1
DIR_DUMP=dump
mkdir -p $DIR_DUMP

DUMP=$DIR_DUMP/$BR.dump

ovs-ofctl dump-flows $BR | 
awk '
{ 
	if (NR != 1) { 
		for ( i=3; i <= NF; i++ ) {  
			if ( index($i, "table=") > 0 ) {
				sub(/,/,"",$i)
				printf "%-10s ", $i  
			} else  if ( index($i, "priority=") > 0 ) {
				printf "%-40s", $i  
			} else  if ( index($i, "actions=") > 0 ) {
				printf "%-25s", $i
			}
		} 
		print ""
	}
}' > $DUMP
