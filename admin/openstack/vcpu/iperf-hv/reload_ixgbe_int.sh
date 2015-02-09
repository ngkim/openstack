#!/bin/bash -x

IP_ADDR=10.20.20.51
Q_LEN=512

rmmod ixgbe
modprobe ixgbe RSS=4
#modprobe ixgbe
ifconfig p1p1 $IP_ADDR netmask 255.255.255.0 up
ethtool -K p1p1 gro off
ethtool -K p1p1 tso off
ethtool -G p1p1 rx $Q_LEN tx $Q_LEN
sleep 3
ovs-vsctl del-port p1p1
ovs-vsctl add-port br-int p1p1


