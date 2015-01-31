#!/bin/bash

function ctrlnnode_hosts_info_setting() {

    echo "
    # ------------------------------------------------------------------------------
    # 호스트 정보 등록 in /etc/hosts !!!
    # ------------------------------------------------------------------------------
    
    ex)
    211.224.204.156 pub_ctrl    pub_ctrl.west.dj_lab.zo.kt    
    10.0.0.101      controller  controller.west.dj_lab.zo.kt    
    10.0.0.102      cnode01     cnode01.west.dj_lab.zo.kt
    10.0.0.103      cnode02     cnode02.west.dj_lab.zo.kt
    "

    backup_org /etc/hosts
    
cat > /etc/hosts <<EOF
${CONTROLLER_PUBLIC_HOST_IP} ${CONTROLLER_PUBLIC_HOST} ${CONTROLLER_PUBLIC_HOST}.${DOMAIN_APPENDIX}
${CONTROLLER_HOST_IP} ${CONTROLLER_HOST} ${CONTROLLER_HOST}.${DOMAIN_APPENDIX}
${CNODE01_HOST_IP}    ${CNODE01_HOST}    ${CNODE01_HOST}.${DOMAIN_APPENDIX}
${CNODE02_HOST_IP}    ${CNODE02_HOST}    ${CNODE02_HOST}.${DOMAIN_APPENDIX}
EOF

    echo "cat /etc/hosts"        
    cat /etc/hosts

    echo "
    # ------------------------------------------------------------------------------
    # 호스트 이름 등록 in /etc/hostname !!!
    # ------------------------------------------------------------------------------"

    backup_org /etc/hostname
    
cat > /etc/hostname <<EOF
$CONTROLLER_HOST
EOF
    
    echo "cat /etc/hostname"
    cat /etc/hostname
    
}

nic_sample() {
# ------------------------------------------------------------------------------
# The loopback network interface
auto lo
iface lo inet loopback

# mgmt
auto em1
iface em1 inet static
    address 10.0.0.101
    netmask 255.255.255.0

# api
auto em2
iface em2 inet static
    address 211.224.204.156
    netmask 255.255.255.224
    gateway 211.224.204.129
    # dns-* options are implemented by the resolvconf package, if installed
    dns-nameservers 8.8.8.8

# public mgmt
auto em3
iface em3 inet manual
    up ip link set dev $IFACE up
    down ip link set dev $IFACE down

# guest
auto p1p1
iface p1p1 inet manual
    up ip link set dev $IFACE up
    down ip link set dev $IFACE down

# hybrid
auto p1p2
iface p1p2 inet manual
    up ip link set dev $IFACE up
    down ip link set dev $IFACE down
# ------------------------------------------------------------------------------
}

################################################################################
# 하나의 cnode에 모두 설치
################################################################################
ctrlnnode_NIC_setting() {    
    
	_nic_conf="/etc/network/interfaces"
	
	_mgmt_nic=$1
	_mgmt_ip=$2
	_mgmt_subnet_mask=$3
	
	_api_nic=$4
	_api_ip=$5
	_api_subnet_mask=$6
	_api_gw=$7
	_api_dns=$8
	
	_guest_nic=$9
	_ext_nic=${10}
	

    echo "
    # ------------------------------------------------------------------------------
    ### ctrlnnode_NIC_setting(${_nic_conf}) !!!
    # ------------------------------------------------------------------------------"
    
    backup_org ${_nic_conf}

# reboot 되어도 network환경이 적용되도록 설정

cat > ${_nic_conf}<<EOF
# ------------------------------------------------------------------------------
# The loopback network interface
auto lo
iface lo inet loopback

# management network
auto $_mgmt_nic
iface $_mgmt_nic inet static
    address $_mgmt_ip
    netmask $_mgmt_subnet_mask

# api network
auto $_api_nic
iface $_api_nic inet static
    address $_api_ip
    netmask $_api_subnet_mask
    gateway $_api_gw
    # dns-* options are implemented by the resolvconf package, if installed
    dns-nameservers $_api_dns

# guest network
auto $_guest_nic
iface $_guest_nic inet manual
    up ip link set dev \$IFACE up
    down ip link set dev \$IFACE down
    
# external network        
auto $_ext_nic
iface $_ext_nic inet manual
    up ip link set dev \$IFACE up
    down ip link set dev \$IFACE down
EOF

    cat ${_nic_conf}

    ask_continue_stop

    ifconfig $_mgmt_nic $_mgmt_ip netmask $_mgmt_subnet_mask up
    ifconfig $_api_nic  $_api_ip  netmask $_api_subnet_mask up
    ifconfig $_ext_nic   0.0.0.0 up
    ifconfig $_guest_nic 0.0.0.0 up
        
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