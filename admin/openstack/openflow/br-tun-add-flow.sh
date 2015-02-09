#!/bin/bash

usage() {
	echo "Usage: $0 [tunnel_segmentation_id] [local_vlan_id] [patch_int_port_num] [dhcp_mac]"
	echo "          - tunnel_segmentation_id: quantum net-show [net-id]"
	echo "          - local_vlan_id: tag in br-int bridge by running  ovs-vsctl show"
	echo "          - patch_int_port_num: ovs-ofctl show br-tun"
	echo "          - dhcp_mac: ip netns qdhcp-xxx ifconfig"
	echo "   ex) $0 0x1 1 2 fa:16:3e:41:c0:24"
}

#TUN_ID=0x1
#LVID=1
#IN_PORT=2
#DHCP_MAC="fa:16:3e:41:c0:24"

TUN_ID=$1
LVID=$2
IN_PORT=$3
DHCP_MAC=$4

if [ -z $3 ]; then
	usage; exit -1
fi

if [ -z $4 ]; then
    DHCP_MAC="fa:16:3e:ad:fd:f3"
fi

# outbound
echo "Add outbound traffic flows"
ovs-ofctl add-flow br-tun "hard_timeout=0,idle_timeout=0,priority=4,in_port=$IN_PORT,dl_vlan=$LVID,actions=set_tunnel:$TUN_ID,NORMAL"


echo "Add inbound traffic flows"
# inbound bcast/mcast
#ovs-ofctl add-flow br-tun "hard_timeout=0,idle_timeout=0,priority=3,tun_id=$TUN_ID,dl_dst=01:00:00:00:00:00/01:00:00:00:00:00,actions=mod_vlan_vid:$LVID,output:$IN_PORT"
ovs-ofctl add-flow br-tun "hard_timeout=0,idle_timeout=0,priority=3,tun_id=$TUN_ID,actions=mod_vlan_vid:$LVID,output:$IN_PORT"
#ovs-ofctl add-flow br-tun "hard_timeout=0,idle_timeout=0,priority=3,tun_id=$TUN_ID,dl_dst=$DHCP_MAC,actions=mod_vlan_vid:$LVID,NORMAL"
