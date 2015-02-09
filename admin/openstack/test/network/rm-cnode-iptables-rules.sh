#!/bin/bash

source "$MNG_ROOT/include/print.sh"
source "$MNG_ROOT/openstack/test/network/cfg/test-node.cfg"

MODE="CFG-NODE-NET"

C_NODE=211.224.204.156

ssh $C_NODE "./admin/openstack/iptables/update-neutron-iptables-rules.sh $TAP_GREEN_ID 0.0.0.0/0 0.0.0.0/0"
ssh $C_NODE "./admin/openstack/iptables/update-neutron-iptables-rules.sh $TAP_ORANGE_ID 0.0.0.0/0 0.0.0.0/0"
