#!/bin/bash

NSHOME=$HOME/admin/openstack/netns
NSNAME=`cat $NSHOME/nsname`
NETNS_CMD="ip netns exec $NSNAME $@"

$NETNS_CMD

