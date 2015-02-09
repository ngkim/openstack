#!/bin/bash

source "$MNG_ROOT/include/print.sh"
source "$MNG_ROOT/openstack/test/network/test-node.cfg"

MODE="CFG-NODE-NET"

ssh east-c-1 "./admin/openstack/iptables/update-neutron-iptables-rules.sh $TAP_GREEN_ID 0.0.0.0/0 0.0.0.0/0"
ssh east-c-1 "./admin/openstack/iptables/update-neutron-iptables-rules.sh $TAP_ORANGE_ID 0.0.0.0/0 0.0.0.0/0"
