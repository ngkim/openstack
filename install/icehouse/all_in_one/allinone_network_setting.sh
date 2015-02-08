#!/bin/bash

function all_in_one_hosts_info_setting() {

    echo "
    # ------------------------------------------------------------------------------
    # 호스트 정보 등록 in /etc/hosts !!!
    # ------------------------------------------------------------------------------"
    
    mv /etc/hosts /etc/hosts_$(date +"%Y%m%d-%T").bak
cat > /etc/hosts <<EOF
${CONTROLLER_HOST} ${DOMAIN_POD_HOST_CTRL}      ${DOMAIN_POD_HOST_CTRL}.${DOMAIN_APPENDIX}
${COM01_MGMT_IP}   ${DOMAIN_POD_HOST_CNODE01}   ${DOMAIN_POD_HOST_CNODE01}.${DOMAIN_APPENDIX}
EOF

    echo "cat /etc/hosts"        
    cat /etc/hosts

    echo "
    # ------------------------------------------------------------------------------
    # 호스트 이름 등록 in /etc/hostname !!!
    # ------------------------------------------------------------------------------"

mv /etc/hostname /etc/hostname_$(date +"%Y%m%d-%T").bak
cat > /etc/hostname <<EOF
$DOMAIN_POD_HOST_CTRL
EOF
    
    echo "cat /etc/hostname"
    cat /etc/hostname
    
}

################################################################################
# allinone_havana: 10G NIC 2개 1G NIC 6개
#
#   eth0(1G)    -> mgmt
#   eth1(1G)    -> api internet
#   eth2(1G)    -> external
#   eth3(1G)    -> 
#   eth4(10G)   -> guest
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
	_guest_nic=${10}
	_hbrd_nic=${11}

    echo "
    # ------------------------------------------------------------------------------
    ### all_in_one_NIC_setting(${_nic_conf}) !!!
    # ------------------------------------------------------------------------------"
    
mv ${_nic_conf} ${_nic_conf}_$(date +"%Y%m%d-%T").bak

# reboot 되어도 network환경이 적용되도록 설정

cat /etc/network/interfaces.d/eth0.cfg

cat > ${_nic_conf}<<EOF
# ------------------------------------------------------------------------------
# The loopback network interface
auto lo
iface lo inet loopback

source /etc/network/interfaces.d/*.cfg
EOF

_nic_conf_dir="/etc/network/interfaces.d"
mkdir -p $_nic_conf_dir

mgmt_nic_conf="${_nic_conf_dir}/${_mgmt_nic}.cfg"
api_nic_conf="${_nic_conf_dir}/${_api_nic}.cfg"
ext_nic_conf="${_nic_conf_dir}/${_ext_nic}.cfg"
gst_nic_conf="${_nic_conf_dir}/${_guest_nic}.cfg"
hbr_nic_conf="${_nic_conf_dir}/${_hbrd_nic}.cfg"

cat > ${mgmt_nic_conf}<<EOF
# management network
auto $_mgmt_nic
iface $_mgmt_nic inet static
    address $_mgmt_ip
    netmask $_mgmt_subnet_mask
EOF

cat > ${api_nic_conf}<<EOF
# api network
auto $_api_nic
iface $_api_nic inet static
    address $_api_ip
    netmask $_api_subnet_mask
    gateway $_api_gw
    # dns-* options are implemented by the resolvconf package, if installed
    dns-nameservers $_api_dns
EOF

cat > ${ext_nic_conf}<<EOF
# external network        
auto $_ext_nic
iface $_ext_nic inet manual
    up ip link set dev \$IFACE up
    down ip link set dev \$IFACE down
EOF

cat > ${gst_nic_conf}<<EOF
# guest network
auto $_guest_nic
iface $_guest_nic inet manual
    up ip link set dev \$IFACE up
    down ip link set dev \$IFACE down
EOF

cat > ${hbr_nic_conf}<<EOF
# hybrid network
auto $_hbrd_nic
iface $_hbrd_nic inet manual
    up ip link set dev \$IFACE up
    down ip link set dev \$IFACE down
EOF

    cat ${_nic_conf}

    ask_continue_stop

    ifconfig $_mgmt_nic $_mgmt_ip netmask $_mgmt_subnet_mask up
    ifconfig $_api_nic  $_api_ip  netmask $_api_subnet_mask up
    ifconfig $_ext_nic   0.0.0.0 up
    ifconfig $_guest_nic 0.0.0.0 up
    ifconfig $_hbrd_nic  0.0.0.0 up
        
    # public nic에 default gw 설정
    route add default gw $_api_gw dev $_api_nic
    
    # dns 설정
    echo "nameserver $_api_dns" | tee -a /etc/resolv.conf

    echo "
    # ------------------------------------------------------------------------------
    # 네트워크 설정 확인 !!!
    # ------------------------------------------------------------------------------"
    route -n
    echo "----------------------------------------------------------------------"
    ip a | grep UP
    echo "----------------------------------------------------------------------"
    ifconfig
    echo "----------------------------------------------------------------------"
}
