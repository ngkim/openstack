#!/bin/bash

source "provider-net.ini"
source "../include/command_util.sh"
source "../include/provider_net_util.sh"

VLAN_GR="120"
SBN_GRN="subnet-vlan-${VLAN_GR}"
NET_GRN="net-vlan-${VLAN_GR}"

delete_provider_subnet 	$SBN_GRN
delete_provider_net 	$NET_GRN

VLAN_GR="121"
SBN_GRN="subnet-vlan-${VLAN_GR}"
NET_GRN="net-vlan-${VLAN_GR}"

delete_provider_subnet 	$SBN_GRN
delete_provider_net 	$NET_GRN

VLAN_GR="15"
SBN_GRN="subnet-vlan-${VLAN_GR}"
NET_GRN="net-vlan-${VLAN_GR}"

delete_provider_subnet 	$SBN_GRN
delete_provider_net 	$NET_GRN

VLAN_GR="120"
SBN_GRN="subnet-vlan-wan-${VLAN_GR}"
NET_GRN="net-vlan-wan-${VLAN_GR}"

delete_provider_subnet 	$SBN_GRN
delete_provider_net 	$NET_GRN
