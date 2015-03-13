#!/bin/bash

LOC_HOST=211.224.204.160
LOC_PORT=80
DST_HOST=10.0.0.101
DST_PORT=80

#iptables -t nat -A PREROUTING -i eth0 -p tcp --dport $LOC_PORT -j DNAT --to $DST_HOST:$LOC_PORT

echo "iptables -t nat -A PREROUTING -p tcp -d $LOC_HOST --dport $LOC_PORT -j DNAT --to-destination $DST_HOST"
iptables -t nat -A PREROUTING -p tcp -d $LOC_HOST --dport $LOC_PORT -j DNAT --to-destination $DST_HOST

echo ""
iptables -t nat -L
