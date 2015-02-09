#!/bin/bash

source "./vm-access.cfg"
source "$MNG_ROOT/include/print.sh"

MODE="VM-CONFIG"

print_info $MODE "${VM_IP}: config ip_forward"
ssh $N_NODE "$DIR_BIN/netns.sh ssh $VM_ADM@$VM_IP echo 1 > /proc/sys/net/ipv4/ip_forward"

print_info $MODE "${VM_IP}: check ip_forward"
ssh $N_NODE "$DIR_BIN/netns.sh ssh $VM_ADM@$VM_IP cat /proc/sys/net/ipv4/ip_forward"

