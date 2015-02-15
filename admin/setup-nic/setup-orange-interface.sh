#!/bin/bash

source "$MNG_ROOT/include/print.sh"

MODE="TEST-ORANGE"

NETNAME="ORANGE"
DEV_IW=em3
OVS_IW=br-hybrid
VLAN_ID=2501
IP_ADDR=192.168.52.11/24

print_info $MODE "remove $DEV_IW from $OVS_IW"
ovs-vsctl del-port $OVS_IW $DEV_IW

print_info $MODE "create an interface for $NW_NAME vlan $VLAN_ID for $DEV_IW"
rmmod 8021q
modprobe 8021q
vconfig add $DEV_IW $VLAN_ID

print_info $MODE "configure ip address $IP_ADDR for $NW_NAME interface $DEV_IW.$VLAN_ID"
ifconfig $DEV_IW.$VLAN_ID $IP_ADDR up
