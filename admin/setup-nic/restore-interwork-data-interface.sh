#!/bin/bash

source "$MNG_ROOT/include/print.sh"

MODE="ID-TEST"

DEV_IW=em3
OVS_IW=br-hybrid
VLAN_GREEN=2001

print_info $MODE "remove ip address from GREEN interface $DEV_IW.$VLAN_GREEN"
ifconfig $DEV_IW.$VLAN_GREEN 0.0.0.0

print_info $MODE "delete GREEN interface $DEV_IW.$VLAN_GREEN"
vconfig rem $DEV_IW.$VLAN_GREEN

print_info $MODE "restore $DEV_IW to $OVS_IW"
ovs-vsctl add-port $OVS_IW $DEV_IW

print_info $MODE "list ports in $OVS_IW"
ovs-vsctl list-ports $OVS_IW
