#!/bin/bash

function cnode_hosts_info_setting() {

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
${CNODE03_HOST_IP}    ${CNODE03_HOST}    ${CNODE03_HOST}.${DOMAIN_APPENDIX}
EOF

    echo "cat /etc/hosts"        
    cat /etc/hosts

    echo "
    # ------------------------------------------------------------------------------
    # 호스트 이름 등록 in /etc/hostname !!!
    # ------------------------------------------------------------------------------"

    backup_org /etc/hostname
    
cat > /etc/hostname <<EOF
$COM_MGMT_HOST
EOF
    
    echo "cat /etc/hostname"
    cat /etc/hostname
    
}

nic_sample() {

# ------------------------------------------------------------------------------
# The loopback network interface
auto lo
iface lo inet loopback

# management network
auto em1
iface em1 inet static
    address 10.0.0.102
    netmask 255.255.255.0

# guest network
auto p1p1
iface p1p1 inet manual
    up ip link set dev $IFACE up
    down ip link set dev $IFACE down

# hybrid network
auto p1p2
iface p1p2 inet manual
    up ip link set dev $IFACE up
    down ip link set dev $IFACE down

# public mgmt network
auto em2
iface em2 inet static
    address 211.224.204.157
    netmask 255.255.255.224
    gateway 211.224.204.129
    # dns-* options are implemented by the resolvconf package, if installed
    dns-nameservers 8.8.8.8

}

################################################################################
# 하나의 cnode에 모두 설치
################################################################################
cnode_NIC_setting() {    
    
	_nic_conf="/etc/network/interfaces"
	
	_mgmt_nic=$1
	_mgmt_ip=$2
	_mgmt_subnet_mask=$3

	_guest_nic=$4
	_hbrd_nic=$5
	
	_public_mgmt_nic=$6
	_public_mgmt_ip=$7
	_public_mgmt_subnet_mask=$8
	_public_mgmt_gw=$9
	_public_mgmt_dns=${10}
	
	echo "## CNODE INFO"
	printf "%-30s => %s\n" _mgmt_nic         $_mgmt_nic
	printf "%-30s => %s\n" _mgmt_ip         $_mgmt_ip
	printf "%-30s => %s\n" _mgmt_subnet_mask         $_mgmt_subnet_mask
	printf "%-30s => %s\n" _guest_nic         $_guest_nic
	printf "%-30s => %s\n" _hbrd_nic         $_hbrd_nic
	printf "%-30s => %s\n" _public_mgmt_nic         $_public_mgmt_nic
	printf "%-30s => %s\n" _public_mgmt_ip         $_public_mgmt_ip
	printf "%-30s => %s\n" _public_mgmt_subnet_mask         $_public_mgmt_subnet_mask
	printf "%-30s => %s\n" _public_mgmt_gw         $_public_mgmt_gw
	printf "%-30s => %s\n" _public_mgmt_dns         $_public_mgmt_dns

    ask_continue_stop

    echo "
    # ------------------------------------------------------------------------------
    ### all_in_one_NIC_setting(${_nic_conf}) !!!
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

# guest network
auto $_guest_nic
iface $_guest_nic inet manual
    up ip link set dev \$IFACE up
    down ip link set dev \$IFACE down

# hybrid network
auto $_hbrd_nic
iface $_hbrd_nic inet manual
    up ip link set dev \$IFACE up
    down ip link set dev \$IFACE down

# public mgmt network
auto $_public_mgmt_nic
iface $_public_mgmt_nic inet static
    address $_public_mgmt_ip
    netmask $_public_mgmt_subnet_mask
    gateway $_public_mgmt_gw
    # dns-* options are implemented by the resolvconf package, if installed
    dns-nameservers $_public_mgmt_dns

EOF

    cat ${_nic_conf}

    ask_continue_stop

    ifconfig $_mgmt_nic $_mgmt_ip netmask $_mgmt_subnet_mask up
    ifconfig $_guest_nic 0.0.0.0 up
    ifconfig $_hbrd_nic  0.0.0.0 up
    ifconfig $_public_mgmt_nic  $_public_mgmt_ip  netmask $_public_mgmt_subnet_mask up
            
    # public nic에 default gw 설정
    route add default gw $_public_mgmt_gw dev $_public_mgmt_nic
    
    # dns 설정
    echo "nameserver $_public_mgmt_dns" | tee -a /etc/resolv.conf

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


