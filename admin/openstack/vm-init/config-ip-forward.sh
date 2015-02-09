#!/bin/bash

source "./vm-access.cfg"

echo "${VM_IP}: config ip_forward"
echo 1 > /proc/sys/net/ipv4/ip_forward

echo "${VM_IP}: check ip_forward"
cat /proc/sys/net/ipv4/ip_forward

