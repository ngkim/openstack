#!/bin/bash

source "$MNG_ROOT/include/print.sh"

MODE="PERF-TEST"
DEV_IW=em3
OVS_IW=br-hybrid
VLAN_GREEN=2001
IP_GREEN=192.168.1.11/24

print_info $MODE "remove $DEV_IW from $OVS_IW"
ovs-vsctl del-port $OVS_IW $DEV_IW

print_info $MODE "create an interface for GREEN vlan $VLAN_GREEN for $DEV_IW"
modprobe 8021q
vconfig add $DEV_IW $VLAN_GREEN

print_info $MODE "configure ip address $IP_GREEN for GREEN interface $DEV_IW.$VLAN_GREEN"
ifconfig $DEV_IW.$VLAN_GREEN $IP_GREEN up
