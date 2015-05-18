#!/bin/bash

source "provider-net.ini"
source "../include/command_util.sh"
source "../include/provider_net_util.sh"

echo "======== PROVIDER NET: LAN ========"
create_provider_net 	$NET_LAN $PHYSNET_LAN 	$VLAN_LAN
create_provider_subnet 	$NET_LAN $SBNET_LAN 	$CIDR_LAN

echo "======== PROVIDER NET: WAN ========"
create_provider_net 	$NET_WAN $PHYSNET_WAN 	$VLAN_WAN
create_provider_subnet 	$NET_WAN $SBNET_WAN	$CIDR_WAN
