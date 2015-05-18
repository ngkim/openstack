#!/bin/bash

file_name=$1
_nic_lan=$2
_ip_lan=$3
_nic_wan=$4
_ip_wan=$5
_ip_gw=$6

cat > $file_name <<EOF
#!/bin/bash

echo "
################################################################################
#
#   VM :: User Data Action
#
################################################################################
"
echo "
# ---------------------------------------------------
# 0. parameters 
# ---------------------------------------------------
#    _nic_lan= $_nic_lan
#    _ip_lan= $_ip_lan
#    _nic_wan= $_nic_wan
#    _ip_wan= $_ip_wan
#    _ip_gw= $_ip_gw
# ---------------------------------------------------
"

echo "
# ---------------------------------------------------
# 1. install tools
# ---------------------------------------------------
"

apt-get -y update  
apt-get -y install iperf ifstat sysstat bridge-utils

echo "
# --------------------------------------------------- 
# 2. nic activate
# ---------------------------------------------------
"
echo "ifconfig $_nic_lan up"
ifconfig $_nic_lan up

echo "ifconfig $_nic_wan up"
ifconfig $_nic_wan up

echo "
# --------------------------------------------------- 
# 3. allocate IP
# ---------------------------------------------------
"
echo "ifconfig $_nic_lan $_ip_lan up"
ifconfig $_nic_lan $_ip_lan up

echo "ifconfig $_nic_wan $_ip_wan up"
ifconfig $_nic_wan $_ip_wan up

echo "
# --------------------------------------------------- 
# 4. apply nat rules
# ---------------------------------------------------
"
echo "ip route del default"
ip route del default

echo "ip route add default via $_ip_gw"
ip route add default via $_ip_gw

echo "
# --------------------------------------------------- 
# 5. enable ip forwarding
# ---------------------------------------------------
"
echo "echo 1 > /proc/sys/net/ipv4/ip_forward"
echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -A FORWARD -i $_nic_lan -o $_nic_wan -s $_cidr_lan -m conntrack --ctstate NEW -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -t nat -F POSTROUTING
iptables -t nat -A POSTROUTING -o $_nic_wan -j MASQUERADE

echo "
################################################################################
#
#   End User Data Action
#
################################################################################
"

EOF
