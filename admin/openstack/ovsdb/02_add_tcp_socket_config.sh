#!/bin/bash

OVS_SCRIPT="/usr/share/openvswitch/scripts/ovs-ctl"
OVS_SCRIPT_LOCAL="ovs-ctl.bak"
OVS_SCRIPT_NEW="ovs-ctl.new"
OVS_TCP_PORT=6632

echo "=== 2. append a line for listening tcp connection to $OVS_SCRIPT"

echo "    --- 2-1. copy $OVS_SCRIPT to $OVS_SCRIPT_LOCAL"
cp $OVS_SCRIPT $OVS_SCRIPT_LOCAL
cp $OVS_SCRIPT_LOCAL $OVS_SCRIPT_NEW

echo "    --- 2-2. append config for listening tcp connection to  $OVS_SCRIPT_NEW"

# sed -i (replace original file)
# a \ (to use leading spaces before 'set')
sed -i '/remote=punix/ { 
a \        set \"\$@\" --remote=ptcp:'$OVS_TCP_PORT'
}' $OVS_SCRIPT_NEW

echo "    --- 2-3. copy new configuration to $OVS_SCRIPT"
cp $OVS_SCRIPT_NEW $OVS_SCRIPT

echo "    --- 2-4. clear new configuration file"
rm $OVS_SCRIPT_NEW

echo "    --- 2-5. resetart openvswitch-switch"
service openvswitch-switch restart


