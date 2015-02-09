#!/bin/bash

usage() {
	echo "Usage: $0 [BRIDGE]"
	echo "   ex) $0 br-tun"
} 
	
if [ -z $1 ]; then
	usage; exit -1
fi

BR=$1

IS_RUN=1
while [ $IS_RUN -eq 1 ]; do
	clear
	#ovs-ofctl dump-flows $BR | awk '{print $4, $6, $7, $8}'
	ovs-ofctl dump-flows $BR | awk '{ if($7 ~ /^hard_age/) { printf(" %-20s %-70s %s\n", $4, $8, $9) } else { printf(" %-20s %-70s %s\n", $4, $7, $8)}}'
	sleep 1
done
