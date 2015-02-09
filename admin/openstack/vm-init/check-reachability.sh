#!/bin/bash

source "./vm-access.cfg"

check_ping() {
	NET_NAME=$1
	DST_IP=$2

	echo "${VM_IP}.${NET_NAME}: ping to NODE-${NET_NAME}= $DST_IP"
	ping -c 3 $DST_IP"
}

check_ping "GREEN" $NODE_GREEN
check_ping "ORANGE" $NODE_ORANGE

