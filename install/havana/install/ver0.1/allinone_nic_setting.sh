#!/bin/bash

################################################################################
# allinone_havana: 10G NIC 2개 1G NIC 6개
#
#   eth0(1G)    -> mgmt
#   eth1(1G)    -> api internet
#   eth2(1G)    -> external
#   eth3(1G)    -> 
#   eth4(10G)   -> private
#   eth5(1G)    -> 
#   eth6(1G)    -> 
#   eth7(10G)   -> hybrid
################################################################################

################################################################################
# 하나의 cnode에 모두 설치
################################################################################
all_in_one_NIC_setting() {    
    
	_nic_conf="/etc/network/interfaces"
	
	_mgmt_nic=$1
	_mgmt_ip=$2
	_mgmt_subnet_mask=$3
	
	_api_nic=$4
	_api_ip=$5
	_api_subnet_mask=$6
	_api_gw=$7
	_api_dns=$8
	
	_ext_nic=$9
	_prvt_nic=${10}
	_hbrd_nic=${11}

    echo "
    # ------------------------------------------------------------------------------
    ### hanvan_all_in_one_NIC_setting(${_nic_conf}) !!!
    # ------------------------------------------------------------------------------"
    
    mv ${_nic_conf} ${_nic_conf}.org

cat > ${_nic_conf}<<EOF
# ------------------------------------------------------------------------------
# The loopback network interface
auto lo
iface lo inet loopback

# management network
auto $_mgmt_nic
iface $_mgmt_nic inet static
    address $_mgmt_ip           # 10.0.0.101
    netmask $_mgmt_subnet_mask  # 255.255.255.0
    # gateway 10.0.0.1 # -> 적어주면 routing table에 default gateway로 설정됨

# api network
auto $_api_nic
iface $_api_nic inet static
    address $_api_ip
    netmask $_api_subnet_mask
    gateway $_api_gw
    # dns-* options are implemented by the resolvconf package, if installed
    dns-nameservers $_api_dns       # 8.8.8.8
    
# external network 
auto $_ext_nic
iface $_ext_nic inet manual
    up ip link set dev \$IFACE up
    down ip link set dev \$IFACE down

# private network 
auto $_prvt_nic
iface $_prvt_nic inet manual
    up ip link set dev \$IFACE up
    down ip link set dev \$IFACE down

# hybrid network
auto $_hbrd_nic
iface $_hbrd_nic inet manual
    up ip link set dev \$IFACE up
    down ip link set dev \$IFACE down
EOF

echo "
# ------------------------------------------------------------------------------
    allinone_havana nic setting check:: ${_nic_conf}
# ------------------------------------------------------------------------------"
cat ${_nic_conf}


}



