#!/bin/bash

NSHOME=$HOME/workspace/openstack/admin/openstack/netns
NSNAME=`cat $NSHOME/nsname`
NETNS_CMD="ip netns exec $NSNAME $@"

$NETNS_CMD

