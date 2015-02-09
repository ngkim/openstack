#!/bin/bash

iptables -F
iptables -A INPUT -d 192.168.51.2 -p tcp --dport 5001 -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -s 0.0.0.0/0 -d 0.0.0.0/0 -p all -j REJECT

