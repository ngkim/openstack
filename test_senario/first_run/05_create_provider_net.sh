#!/bin/bash

source "provider-net.ini"
source "../include/command_util.sh"
source "../include/provider_net_util.sh"

echo "======== PROVIDER NET: GREEN ========"
create_provider_net 	$NET_GRN $PHYSNET_NAME 	$VLAN_GRN
create_provider_subnet 	$NET_GRN $SBNET_GRN 	$CIDR_GRN

echo "======== PROVIDER NET: ORANGE ========"
create_provider_net 	$NET_ORG $PHYSNET_NAME 	$VLAN_ORG
create_provider_subnet 	$NET_ORG $SBNET_ORG 	$CIDR_ORG
