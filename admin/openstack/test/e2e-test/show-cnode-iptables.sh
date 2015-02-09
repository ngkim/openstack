#!/bin/bash

source "$MNG_ROOT/include/print.sh"
source "$MNG_ROOT/openstack/test/network/test-node.cfg"

MODE="CFG-NODE-NET"

ssh east-c-1 "iptables -L -n"
