#!/bin/bash

source "$MNG_ROOT/include/print.sh"
source "$MNG_ROOT/openstack/test/e2e-test/test-node.cfg"

MODE="CFG-NODE-NET"

# config_dev_ip 221.145.180.79 eth2 192.168.1.2 /24
config_dev_ip() {
	NODE=$1
	DEV=$2
	DEV_IP=$3
	DEV_IP_NET_MASK=$4

	reset_dev_ip $NODE $DEV

	print_info $MODE "$NODE: config ip address of dev= $DEV ip= $DEV_IP $DEV_IP_NET_MASK"
	ssh $NODE ifconfig $DEV ${DEV_IP}${DEV_IP_NET_MASK}
}

reset_dev_ip() {
	NODE=$1
	DEV=$2

    ### reset
	print_info $MODE "$NODE: reset ip address of dev= $DEV"
	ssh $NODE ifconfig $DEV 0.0.0.0
}

get_dev_ip() {
	NODE=$1
	DEV=$2

	print_info $MODE "$NODE: get ip address of dev= $DEV"
	ssh $NODE ifconfig $DEV
}

set_route_gw() {
	NODE=$1
	NET=$2
	GW_IP=$3
	DEV=$4

	print_info $MODE "$NODE: add route for net= $NET with gw= $GW_IP through DEV= $DEV"
	ssh $NODE route add -net $NET gw $GW_IP dev $DEV
}

echo "$NODE1"
config_dev_ip $NODE1 $NODE1_DEV $NODE1_DEV_IP $NODE1_DEV_IP_NET_MASK 
get_dev_ip $NODE1 $NODE1_DEV
#set_route_gw $NODE1 $NET_ORANGE $NODE1_DEV_GW $NODE1_DEV

config_dev_ip $NODE2 $NODE2_DEV $NODE2_DEV_IP $NODE2_DEV_IP_NET_MASK 
get_dev_ip $NODE2 $NODE2_DEV
#set_route_gw $NODE2 $NET_GREEN $NODE2_DEV_GW $NODE2_DEV

ssh east-c-3 "./admin/openstack/iptables/update-neutron-iptables-rules.sh $TAP_GREEN_ID $NET_ORANGE $NET_GREEN"
ssh east-c-3 "./admin/openstack/iptables/update-neutron-iptables-rules.sh $TAP_ORANGE_ID $NET_GREEN $NET_ORANGE"
