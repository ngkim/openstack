#!/bin/bash

ITF_IN=em1
ITF_OUT=em2
SBNET=10.0.0.0/24

echo "Please run \"echo 1 > /proc/sys/net/ipv4/ip_forward\" as root"

echo "1) Clear nat tables"
sudo iptables -F FORWARD
sudo iptables -t nat -F PREROUTING
sudo iptables -t nat -F POSTROUTING

echo "2) add MASQUERADE rule"
sudo iptables -t nat -A POSTROUTING -o $ITF_OUT -j MASQUERADE
sudo iptables -A FORWARD -i $ITF_IN -o $ITF_OUT -s $SBNET -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
