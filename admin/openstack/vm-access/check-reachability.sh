#!/bin/bash

source "./vm-access.cfg"
source "$MNG_ROOT/include/print.sh"

MODE="VM-REACHABILITY"

check_ping() {
	NET_NAME=$1
	DST_IP=$2

	print_info $MODE "${VM_IP}.${NET_NAME}: ping to NODE-${NET_NAME}= $DST_IP"
	ssh $N_NODE "$DIR_BIN/netns.sh ssh $VM_ADM@$VM_IP ping -c 3 $DST_IP"
}

check_ping "GREEN" $NODE_GREEN
check_ping "ORANGE" $NODE_ORANGE

