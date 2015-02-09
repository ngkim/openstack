#!/bin/bash

source "provider-net.ini"
source "../include/command_util.sh"
source "../include/provider_net_util.sh"

echo "======== PROVIDER NET: GREEN ========"
delete_provider_subnet 	$SBNET_GRN
delete_provider_net 	$NET_GRN

echo "======== PROVIDER NET: ORANGE ========"
delete_provider_subnet 	$SBNET_ORG
delete_provider_net 	$NET_ORG