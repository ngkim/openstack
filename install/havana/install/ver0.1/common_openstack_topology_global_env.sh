#!/bin/bash

#  common_openstack_topology_global_env.sh


echo '
################################################################################

    openstack install topology 설정에 따른 global_env 설정
    
        :: topology cases
            1) 2 nodes(1: controller & network, 2: compute)
            2) 3 nodes(1: controller 2: network 3: compute)
            3) 1 nodes(1: controller & network & compute)
        :: env info      
            - nodes domain name
            - nodes network env

################################################################################
'

echo "
# ------------------------------------------------------------------------------
# 1. 환경변수 설정 !!!
# ------------------------------------------------------------------------------"

export DEBIAN_FRONTEND=noninteractive

echo "
# -----------------------------------------------
# DNS Naming Variable
# ex) Hostname.POD.LOC.BUSINESS.COMPANY
#       -> cnode01.east.dj_lab.zo.kt
# -----------------------------------------------
"

DOMAIN_COMPANY=kt
DOMAIN_BUSINESS=zo                  # zero office
DOMAIN_LOC=dj_lab                   # host geolocation
DOMAIN_POD=east                     # lack name
DOMAIN_POD_HOST_CTRL=controller     # controller hostname
DOMAIN_POD_HOST_NET=nnode           # network hostname
DOMAIN_POD_HOST_BLOCK=snode         # storage(block) hostname
DOMAIN_POD_HOST_CNODE01=cnode01     # compute_01 hostname
DOMAIN_POD_HOST_CNODE02=cnode02     # compute_02 hostname
DOMAIN_POD_HOST_CNODE03=cnode03     # compute_03 hostname

# cnode01.east.dj_lab.zo.kt
DOMAIN_APPENDIX=${DOMAIN_POD}.${DOMAIN_LOC}.${DOMAIN_BUSINESS}.${DOMAIN_COMPANY}

echo "
################################################################################
#
#   openstack install nodes topology network global variable 
#
################################################################################
"

# external network 접속 네트워크
PHY_EXT_NET=physnet_ext

# vlan용 private network range:
# LJG: physnet_private으로 주고 싶으나 horizon에서 multi-network가 설정되 있을때,
#      알파벳순으로 default network를 설정하므로 physnet_guest을 private로 설정
PHY_PRVT_NET=physnet_guest
PHY_PRVT_NET_RANGE=${PHY_PRVT_NET}:2001:4000

# vlan용 hybrid network range
PHY_HYBRID_NET=physnet_hybrid
PHY_HYBRID_NET_RANGE=${PHY_HYBRID_NET}:10:2000

LOG_INT_BR=br-int
LOG_PRVT_BR=br-private
LOG_HYBRID_BR=br-hybrid
LOG_EXT_BR=br-ex


east_havana_network_interface_status() {
	# ------------------------------------------------------------------------------
    # The loopback network interface
    auto lo
    iface lo inet loopback

    # management network
    auto eth0
    iface eth0 inet static
        address 10.0.0.101
        netmask 255.255.255.0

    # api network
    auto eth1
    iface eth1 inet static
        address 211.224.204.156
        netmask 255.255.255.224
        gateway 211.224.204.129
        # dns-* options are implemented by the resolvconf package, if installed
        dns-nameservers 8.8.8.8

    # external network 
    auto eth2
    iface eth2 inet manual
        up ip link set dev $IFACE up
        down ip link set dev $IFACE down

    # private network 
    auto eth4
    iface eth4 inet manual
        up ip link set dev $IFACE up
        down ip link set dev $IFACE down

    # hybrid network
    auto eth7
    iface eth7 inet manual
        up ip link set dev $IFACE up
        down ip link set dev $IFACE down
    # ------------------------------------------------------------------------------
}

west_havana_network_interface_status() {
	# ------------------------------------------------------------------------------
    # The loopback network interface
    auto lo
    iface lo inet loopback

    # management network
    auto eth0
    iface eth0 inet static
        address 10.0.0.101
        netmask 255.255.255.0

    # api network
    auto eth1
    iface eth1 inet static
        address 211.224.204.156
        netmask 255.255.255.224
        gateway 211.224.204.129
        # dns-* options are implemented by the resolvconf package, if installed
        dns-nameservers 8.8.8.8

    # external network 
    auto eth2
    iface eth2 inet manual
        up ip link set dev $IFACE up
        down ip link set dev $IFACE down

    # private network 
    auto eth4
    iface eth4 inet manual
        up ip link set dev $IFACE up
        down ip link set dev $IFACE down

    # hybrid network
    auto eth5
    iface eth5 inet manual
        up ip link set dev $IFACE up
        down ip link set dev $IFACE down
    # ------------------------------------------------------------------------------
}

function openstack_install_1node_env() 
{
    echo "
    # ------------------------------------------------------------------------------
    #   1대의 서버에 오픈스택 설치(controller, nnode, cnode) 
    # ------------------------------------------------------------------------------
    "

    ################################################################################
	# east 최신형: 
    # allinone_havana: 10G NIC 2개 1G NIC 6개
    #
    #   em1, eth0(1G)    -> mgmt
    #   em2, eth1(1G)    -> api internet
    #   em3, eth2(1G)    -> external
    #   em4, eth3(1G)    -> 
    #   em5, eth4(10G)   -> private
    #   em6, eth5(1G)    -> 
    #   em7, eth6(1G)    -> 
    #   em8, eth7(10G)   -> hybrid
    ################################################################################

	################################################################################
    # west 신형: allinone_havana: 1G NIC 4개, 10G NIC 2개
    #
    #   em1, eth0(1G)    -> mgmt
    #   em2, eth1(1G)    -> api internet
    #   em3, eth2(1G)    -> external
    #   em4, eth3(1G)    -> 
    #   em5, eth4(10G)   -> private
    #   em6, eth5(10G)   -> hybrid
    ################################################################################
    
    export CONTROLLER_HOST=10.0.0.101    
    export CONTROLLER_PUBLIC_HOST=211.224.204.156

    #
    # controller node

    CTRL_MGMT_IP=$CONTROLLER_HOST           # management network ip
    CTRL_MGMT_SUBNET_MASK=255.255.255.0

    CTRL_API_IP=$CONTROLLER_PUBLIC_HOST     # horizon api ip
    CTRL_API_SUBNET_MASK=255.255.255.224
    CTRL_API_GW=211.224.204.129
    CTRL_API_DNS=8.8.8.8

    if [ $UBUNTU_VER = "14.04" ];
    then
        CTRL_MGMT_NIC=em1                   # management network nic info
        CTRL_API_NIC=em2                    # horizon api nic info
    else
        CTRL_MGMT_NIC=eth0                  # management network nic info
        CTRL_API_NIC=eth1                   # horizon api nic info
    fi
    
    #
    # network node

    NTWK_MGMT_IP=$CTRL_MGMT_IP              # management network ip
    NTWK_MGMT_SUBNET_MASK=255.255.255.0
        
    NTWK_PUB_MGMT_IP=$CTRL_API_IP           # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함
    NTWK_PUB_MGMT_SUBNET_MASK=$CTRL_API_SUBNET_MASK
    NTWK_PUB_MGMT_GW=$CTRL_API_GW
    NTWK_PUB_MGMT_DNS=$CTRL_API_DNS
    
    if [ $UBUNTU_VER = "14.04" ]
    then
        NTWK_MGMT_NIC=$CTRL_MGMT_NIC        # management network nic info
        NTWK_PRVT_NIC=em5                   # private network trunk
        NTWK_EXT_NIC=em3                    # external network trunk
        NTWK_PUB_MGMT_NIC=$CTRL_API_NIC     # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함
    else
        NTWK_MGMT_NIC=$CTRL_MGMT_NIC        # management network nic info
        NTWK_PRVT_NIC=eth4                  # private network trunk
        NTWK_EXT_NIC=eth2                   # external network trunk
        NTWK_PUB_MGMT_NIC=$CTRL_API_NIC     # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함
    fi

    #
    # compute node 01
    COM01_MGMT_IP=$CTRL_MGMT_IP            # management network ip
    COM01_MGMT_SUBNET_MASK=255.255.255.0
        
    COM01_PUB_MGMT_IP=$CTRL_API_IP          # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함
    COM01_PUB_MGMT_SUBNET_MASK=$CTRL_API_SUBNET_MASK
    COM01_PUB_MGMT_GW=$CTRL_API_GW
    COM01_PUB_MGMT_DNS=$CTRL_API_DNS
    
    if [ $UBUNTU_VER = "14.04" ]
    then
        COM01_MGMT_NIC=$CTRL_MGMT_NIC       # management network ip		
        COM01_PRVT_NIC=em5                  # 10G NIC private network trunk -> trunk 이므로 설정 불필요
        COM01_HYBR_NIC=em6                  # 10G NIC hybrid networkt trunk -> trunk 이므로 설정 불필요
        COM01_PUB_MGMT_NIC=$CTRL_API_NIC
        
    else
        COM01_MGMT_NIC=$CTRL_MGMT_NIC       # management network ip		
        COM01_PRVT_NIC=eth4                 # 10G NIC private network trunk -> trunk 이므로 설정 불필요
        COM01_HYBR_NIC=eth5                 # 10G NIC hybrid networkt trunk -> trunk 이므로 설정 불필요
        COM01_PUB_MGMT_NIC=$CTRL_API_NIC
    fi
    
    
    echo "compute_type $compute_type"
    topology_check
}


function openstack_install_2nodes_env() {

    echo "
    # ------------------------------------------------------------------------------
    #   2대의 서버에 오픈스택 설치( controller/nnode(1대) cnode(1대) )
    # ------------------------------------------------------------------------------
    "

    # 10G NIC 2개와 1G NIC4 개가 임의 순서로 em번호를 할당 받으므로 확인하고 em번호 설정해야 함

    export CONTROLLER_HOST=192.168.0.156
    export CONTROLLER_PUBLIC_HOST=211.224.204.156

    #
    # controller node

    CTRL_MGMT_IP=$CONTROLLER_HOST           # management network ip
    CTRL_MGMT_SUBNET_MASK=255.255.255.0

    CTRL_API_IP=$CONTROLLER_PUBLIC_HOST     # horizon api ip
    CTRL_API_SUBNET_MASK=255.255.255.224
    CTRL_API_GW=211.224.204.129
    CTRL_API_DNS=8.8.8.8

    if [ $UBUNTU_VER = "14.04" ]
    then
        CTRL_MGMT_NIC=em1                   # management network nic info
        CTRL_API_NIC=em3                    # horizon api nic info
    else
        CTRL_MGMT_NIC=eth0                  # management network nic info
        CTRL_API_NIC=eth2                   # horizon api nic info
    fi
    
    NTWK_MGMT_IP=$CTRL_MGMT_IP              # management network ip
    NTWK_MGMT_SUBNET_MASK=$CTRL_MGMT_SUBNET_MASK
        
    NTWK_PUB_MGMT_IP=$CTRL_API_IP           # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함
    NTWK_PUB_MGMT_SUBNET_MASK=$CTRL_API_SUBNET_MASK
    NTWK_PUB_MGMT_GW=$CTRL_API_GW
    NTWK_PUB_MGMT_DNS=$CTRL_API_DNS    

    if [ $UBUNTU_VER = "14.04" ]
    then
        NTWK_MGMT_NIC=em1                   # management network nic info
        NTWK_PRVT_NIC=p1p1                  # 10G NIC : private network trunk  -> trunk 이므로 설정 불필요
        NTWK_EXT_NIC=em4                    # external network trunk -> trunk 이므로 설정 불필요
        NTWK_PUB_MGMT_NIC=em3               # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함
    else
        NTWK_MGMT_NIC=eth0                  # management network nic info
        NTWK_PRVT_NIC=p1p1                  # 10G NIC : private network trunk  -> trunk 이므로 설정 불필요
        NTWK_EXT_NIC=eth3                   # external network trunk -> trunk 이므로 설정 불필요
        NTWK_PUB_MGMT_NIC=eth2              # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함
    fi

    #
    # compute node 01
    COM01_MGMT_IP=192.168.0.157
    COM01_MGMT_SUBNET_MASK=255.255.255.0
        
    COM01_PUB_MGMT_IP=211.224.204.157
    COM01_PUB_MGMT_SUBNET_MASK=255.255.255.224
    COM01_PUB_MGMT_GW=211.224.204.129
    COM01_PUB_MGMT_DNS=8.8.8.8

    if [ $UBUNTU_VER = "14.04" ]
    then
        COM01_MGMT_NIC=em1                  # management network ip
        COM01_PRVT_NIC=p1p1                 # 10G NIC private network trunk -> trunk 이므로 설정 불필요
        COM01_HYBR_NIC=p1p2                 # 10G NIC hybrid networkt trunk -> trunk 이므로 설정 불필요
        COM01_PUB_MGMT_NIC=em4               # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함
    else
        COM01_MGMT_NIC=eth0                 # management network ip
        COM01_PRVT_NIC=p1p1                 # 10G NIC private network trunk -> trunk 이므로 설정 불필요
        COM01_HYBR_NIC=p1p2                 # 10G NIC hybrid networkt trunk -> trunk 이므로 설정 불필요
        COM01_PUB_MGMT_NIC=eth3              # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함
    fi
    
    
    topology_check
    
    
}

function openstack_install_3nodes_env() {

    echo "
    # ------------------------------------------------------------------------------
    #   3대의 서버에 오픈스택 설치( controller(1대), nnode(1대), cnode(1대) )
    # ------------------------------------------------------------------------------
    "

    export CONTROLLER_HOST=10.0.0.11
    export CONTROLLER_PUBLIC_HOST=211.224.204.141

    #
    # controller node

    CTRL_MGMT_IP=$CONTROLLER_HOST           # management network ip
    CTRL_MGMT_SUBNET_MASK=255.255.255.0

    CTRL_API_IP=$CONTROLLER_PUBLIC_HOST     # horizon api ip
    CTRL_API_SUBNET_MASK=255.255.255.224
    CTRL_API_GW=211.224.204.129
    CTRL_API_DNS=8.8.8.8

    if [ $UBUNTU_VER = "14.04" ]
    then
        CTRL_MGMT_NIC=em1                   # management network nic info
        CTRL_API_NIC=em2                    # horizon api nic info
    else
        CTRL_MGMT_NIC=eth0                  # management network nic info
        CTRL_API_NIC=eth1                   # horizon api nic info
    fi
    #
    # network node

    NTWK_MGMT_IP=10.0.0.21              # management network ip
    NTWK_MGMT_SUBNET_MASK=255.255.255.0    
    
    NTWK_PUB_MGMT_IP=211.224.204.144    # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함
    NTWK_PUB_MGMT_SUBNET_MASK=255.255.255.224
    NTWK_PUB_MGMT_GW=211.224.204.129
    NTWK_PUB_MGMT_DNS=8.8.8.8
    

    if [ $UBUNTU_VER = "14.04" ]
    then
        NTWK_MGMT_NIC=em1                   # management network nic info
        NTWK_PRVT_NIC=em2                   # private network trunk  -> trunk 이므로 설정 불필요
        NTWK_EXT_NIC=em3                    # external network trunk -> trunk 이므로 설정 불필요
        NTWK_PUB_MGMT_NIC=em4               # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함
    else
        NTWK_MGMT_NIC=eth0                  # management network nic info
        NTWK_PRVT_NIC=eth1                  # private network trunk  -> trunk 이므로 설정 불필요
        NTWK_EXT_NIC=eth2                   # external network trunk -> trunk 이므로 설정 불필요
        NTWK_PUB_MGMT_NIC=eth3              # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함
    fi

    #
    # compute node 01
    COM01_MGMT_IP=10.0.0.31             # management network ip
    COM01_MGMT_SUBNET_MASK=255.255.255.0
    
    COM01_PUB_MGMT_IP=211.224.204.145   # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함
    COM01_PUB_MGMT_SUBNET_MASK=255.255.255.224
    COM01_PUB_MGMT_GW=211.224.204.129
    COM01_PUB_MGMT_DNS=8.8.8.8

    if [ $UBUNTU_VER = "14.04" ]
    then
        COM01_MGMT_NIC=em1                  # management network ip
        COM01_PRVT_NIC=em2                  # 1G NIC private network trunk -> trunk 이므로 설정 불필요
        COM01_HYBR_NIC=em3                  # 1G NIC hybrid networkt trunk -> trunk 이므로 설정 불필요
        COM01_PUB_MGMT_IP=em4               # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함
    else
        COM01_MGMT_NIC=eth0                 # management network ip
        COM01_PRVT_NIC=eth1                 # 1G NIC private network trunk -> trunk 이므로 설정 불필요
        COM01_HYBR_NIC=eth2                 # 1G NIC hybrid networkt trunk -> trunk 이므로 설정 불필요
        COM01_PUB_MGMT_NIC=eth3              # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함
    fi
    
    topology_check
    
}

topology_check() {
	echo '### check result -----------------------------------------------------'
	echo "## CTRL INFO"
	printf "%-30s => %-20s :: %s\n" CTRL_MGMT_NIC          $CTRL_MGMT_NIC  "controller management nic"
	printf "%-30s => %-20s :: %s\n" CTRL_API_NIC           $CTRL_API_NIC   "controller api-server nic"
	echo ""
	printf "%-30s => %-20s :: %s\n" CTRL_MGMT_IP           $CTRL_MGMT_IP   "controller management ip"          
	printf "%-30s => %-20s :: %s\n" CTRL_MGMT_SUBNET_MASK  $CTRL_MGMT_SUBNET_MASK "controller management ip subnet mask"
	echo ""
	printf "%-30s => %-20s :: %s\n" CTRL_API_IP            $CTRL_API_IP    "controller api-server ip"         
	printf "%-30s => %-20s :: %s\n" CTRL_API_SUBNET_MASK   $CTRL_API_SUBNET_MASK "controller api-server ip subnet mask"
	printf "%-30s => %-20s :: %s\n" CTRL_API_GW            $CTRL_API_GW    "controller api-server gateway ip"
	printf "%-30s => %-20s :: %s\n" CTRL_API_DNS           $CTRL_API_DNS   "controller api-server dns ip"	
	printf ""
	       
	echo ""                                                                                                      
	echo "## NTWK INFO"
	printf "%-30s => %-20s :: %s\n" NTWK_MGMT_NIC          $NTWK_MGMT_NIC  "nnode management nic"
    printf "%-30s => %-20s :: %s\n" NTWK_PRVT_NIC          $NTWK_PRVT_NIC  "nnode private nic"
    printf "%-30s => %-20s :: %s\n" NTWK_EXT_NIC           $NTWK_EXT_NIC   "nnode external nic"
    printf "%-30s => %-20s :: %s\n" NTWK_PUB_MGMT_NIC      $NTWK_PUB_MGMT_NIC "nnode public nic(tmp, delete after install sw)"
    echo ""
	printf "%-30s => %-20s :: %s\n" NTWK_MGMT_IP           $NTWK_MGMT_IP   "nnode management ip"
	printf "%-30s => %-20s :: %s\n" NTWK_MGMT_SUBNET_MASK  $NTWK_MGMT_SUBNET_MASK "nnode management ip subnet mask"
	echo ""
	printf "%-30s => %-20s :: %s\n" NTWK_PUB_MGMT_IP       $NTWK_PUB_MGMT_IP   "nnode public install ip(tmp, delete after install sw)"
	printf "%-30s => %-20s :: %s\n" NTWK_PUB_MGMT_SUBNET_MASK $NTWK_PUB_MGMT_SUBNET_MASK "nnode public install ip subnet mask"
	printf "%-30s => %-20s :: %s\n" NTWK_PUB_MGMT_GW       $NTWK_PUB_MGMT_GW   "nnode public install gateway ip"
	printf "%-30s => %-20s :: %s\n" NTWK_PUB_MGMT_DNS      $NTWK_PUB_MGMT_DNS  "nnode public install dns ip"
	
	echo ""
	echo "## CNODE INFO"
	printf "%-30s => %-20s :: %s\n" COM01_MGMT_NIC         $COM01_MGMT_NIC     "cnode management nic"
    printf "%-30s => %-20s :: %s\n" COM01_PRVT_NIC         $COM01_PRVT_NIC     "cnode private nic"          
    printf "%-30s => %-20s :: %s\n" COM01_HYBR_NIC         $COM01_HYBR_NIC     "cnode hybrid nic"
    printf "%-30s => %-20s :: %s\n" COM01_PUB_MGMT_NIC     $COM01_PUB_MGMT_NIC "cnode public nic(tmp, delete after install sw)"
    echo ""        
	printf "%-30s => %-20s :: %s\n" COM01_MGMT_IP          $COM01_MGMT_IP  "cnode management ip"             
	printf "%-30s => %-20s :: %s\n" COM01_MGMT_SUBNET_MASK $COM01_MGMT_SUBNET_MASK "cnode management ip subnet mask"
	echo ""                                                            
	printf "%-30s => %-20s :: %s\n" COM01_PUB_MGMT_IP      $COM01_PUB_MGMT_IP  "cnode public install ip(tmp, delete after install sw)"         
	printf "%-30s => %-20s :: %s\n" COM01_PUB_MGMT_SUBNET_MASK $COM01_PUB_MGMT_SUBNET_MASK "cnode public install ip subnet mask"
	printf "%-30s => %-20s :: %s\n" COM01_PUB_MGMT_GW      $COM01_PUB_MGMT_GW  "cnode public install gateway ip"       
	printf "%-30s => %-20s :: %s\n" COM01_PUB_MGMT_DNS     $COM01_PUB_MGMT_DNS "cnode public install dns ip"
	                
	echo '# --------------------------------------------------------------------'
	echo "  이 설정이 맞지 않으면 제대로 설치가 안되니 정확하게 확인하세요 !!!!"
    echo '# --------------------------------------------------------------------'
    echo ""	
    
	ask_continue_stop
}