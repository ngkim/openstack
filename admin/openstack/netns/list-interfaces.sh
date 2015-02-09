#!/bin/bash

source "$MNG_ROOT/include/print.sh"

NS_LIST=`ip netns`

for ns in $NS_LIST; do
	print_info NS "=== Namespace= $ns"
	ip netns exec $ns ip link | grep -v -E "ether|loopback|LOOPBACK"
done

