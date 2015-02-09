#!/bin/bash

source "$MNG_ROOT/include/print.sh"
source "$MNG_ROOT/openstack/test/network/cfg/test-node.cfg"

MODE="CFG-NODE-NET"

CHAIN_GREEN="neutron-openvswi-s$TAP_GREEN_ID"
CHAIN_ORANGE="neutron-openvswi-s$TAP_ORANGE_ID"
ssh east-c-3 "iptables -L $CHAIN_GREEN -n"
ssh east-c-3 "iptables -L $CHAIN_ORANGE -n"
