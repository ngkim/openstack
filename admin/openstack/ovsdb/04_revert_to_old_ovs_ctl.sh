#!/bin/bash

OVS_SCRIPT="/usr/share/openvswitch/scripts/ovs-ctl"
OVS_SCRIPT_LOCAL="ovs-ctl.bak"

echo "=== 4. copy $OVS_SCRIPT_LOCAL to $OVS_SCRIPT"
cp $OVS_SCRIPT_LOCAL $OVS_SCRIPT 

echo "    --- 4-1. resetart openvswitch-switch"
service openvswitch-switch restart


