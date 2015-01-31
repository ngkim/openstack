#!/bin/bash

################################################################################
# nnode: 1G NIC 4개 -> ubuntu 14.04
#
#   em1(1G)    -> mgmt
#   em2(1G)    -> private
#   em3(1G)    -> external
#   em4(1G)    -> tmp internet
################################################################################
NIC_CONF=$1
_mgmt_nic=$2
_mgmt_ip=$3
_mgmt_subnet_mask=$4

_prvt_nic=$5
_ext_nic=$6

_pub_mgmt_nic=$7
_pub_mgmt_ip=$8
_pub_mgmt_subnet=$9
_pub_mgmt_gw=$10
_pub_mgmt_dns=$11

nnode_NIC_setting() {

    echo '
    # ------------------------------------------------------------------------------
    ### nnode_NIC_setting() !!!
    # ------------------------------------------------------------------------------'
    
    mv $NIC_CONF ${NIC_CONF}.bak

cat > ${NIC_CONF} <<EOF
# ------------------------------------------------------------------------------
# The loopback network interface
auto lo
iface lo inet loopback

# management network
auto $_mgmt_nic
iface $_mgmt_nic inet static
    address $_mgmt_ip           
    netmask $_mgmt_subnet_mask  
    # gateway 10.0.0.1 # -> 적어주면 routing table에 default gateway로 설정됨

# private network 
auto $_prvt_nic
iface $_prvt_nic inet manual
    up ip link set dev $IFACE up
    down ip link set dev $IFACE down

# external network
auto $_ext_nic
iface $_ext_nic inet manual
    up ip link set dev $IFACE up
    down ip link set dev $IFACE down

# install public network
auto $_pub_mgmt_nic
iface $_pub_mgmt_nic inet static
    address $_pub_mgmt_ip
    netmask $_pub_mgmt_subnet
    gateway $_pub_mgmt_gw
    # dns-* options are implemented by the resolvconf package, if installed
    dns-nameservers $_pub_mgmt_dns       # 8.8.8.8
# ------------------------------------------------------------------------------
EOF

sudo /etc/init.d/networking restart 

echo 'conde01 nic setting check:: $NIC_CONF'
cat $NIC_CONF

}



