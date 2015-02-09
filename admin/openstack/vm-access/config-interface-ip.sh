#!/bin/bash

source "./vm-access.cfg"
source "$MNG_ROOT/include/print.sh"

MODE="VM-CONFIG"

print_info $MODE "${VM_IP}.GREEN: config interface IP= $DEV_GREEN_IP"
ssh $N_NODE "$DIR_BIN/netns.sh ssh $VM_ADM@$VM_IP ifconfig $DEV_GREEN $DEV_GREEN_IP up"

print_info $MODE "${VM_IP}.GREEN: check interface= $DEV_GREEN"
ssh $N_NODE "$DIR_BIN/netns.sh ssh $VM_ADM@$VM_IP ifconfig $DEV_GREEN"


print_info $MODE "${VM_IP}.ORANGE: config interface IP= $DEV_ORANGE_IP"
ssh $N_NODE "$DIR_BIN/netns.sh ssh $VM_ADM@$VM_IP ifconfig $DEV_ORANGE $DEV_ORANGE_IP up"

print_info $MODE "${VM_IP}.ORANGE: check interface= $DEV_ORANGE"
ssh $N_NODE "$DIR_BIN/netns.sh ssh $VM_ADM@$VM_IP ifconfig $DEV_ORANGE"


