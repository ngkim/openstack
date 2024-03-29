#!/bin/bash

#  allinone_topology_variable_setting.sh


echo '
################################################################################

    openstack install topology 설정에 따른 variable 설정
    
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
DOMAIN_POD=west                     # lack name
DOMAIN_POD_HOST_CTRL=controller     # controller hostname
DOMAIN_POD_HOST_NET=nnode           # network hostname
DOMAIN_POD_HOST_BLOCK=snode         # storage(block) hostname
DOMAIN_POD_HOST_CNODE01=cnode01     # compute_01 hostname
DOMAIN_POD_HOST_CNODE02=cnode02     # compute_02 hostname

# cnode01.east.dj_lab.zo.kt
DOMAIN_APPENDIX=${DOMAIN_POD}.${DOMAIN_LOC}.${DOMAIN_BUSINESS}.${DOMAIN_COMPANY}


echo "
################################################################################
#
#   openstack install nodes topology network global variable 
#
################################################################################
"

function openstack_install_allinnode_env() {

    echo "
    # ------------------------------------------------------------------------------
    #   openstack_install_1node_env: 1대의 서버에 오픈스택 설치
    # ------------------------------------------------------------------------------
    "
    
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
    # allinone_icehouse: 10G NIC 2개 1G NIC 6개
    #
    #   em1(1G)    -> mgmt
    #   em2(1G)    -> api internet
    #   em3(1G)    -> external
    #   em4(1G)    -> 
    #   p1p1(10G)  -> guest
    #   p1p2(10G)  -> hybrid
    ################################################################################
    
    export CONTROLLER_HOST=10.0.0.101
    #export CONTROLLER_PUBLIC_HOST=211.224.204.156
    export CONTROLLER_PUBLIC_HOST=10.0.2.15

    #
    # controller node

    CTRL_MGMT_IP=$CONTROLLER_HOST           # management network ip
    CTRL_MGMT_SUBNET_MASK=255.255.255.0

    CTRL_API_IP=$CONTROLLER_PUBLIC_HOST     # horizon api ip
    CTRL_API_SUBNET_MASK=255.255.255.0
    CTRL_API_GW=10.0.2.2
    CTRL_API_DNS=8.8.8.8

    CTRL_MGMT_NIC=eth1                   # management network nic info
    CTRL_API_NIC=eth0                    # horizon api nic info
   
    #
    # network node

    NTWK_MGMT_IP=$CTRL_MGMT_IP              # management network ip
    NTWK_MGMT_SUBNET_MASK=$CTRL_MGMT_SUBNET_MASK
        
    NTWK_PUB_MGMT_IP=$CTRL_API_IP           # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함
    NTWK_PUB_MGMT_SUBNET_MASK=$CTRL_API_SUBNET_MASK
    NTWK_PUB_MGMT_GW=$CTRL_API_GW
    NTWK_PUB_MGMT_DNS=$CTRL_API_DNS
    
    NTWK_MGMT_NIC=$CTRL_MGMT_NIC        # management network nic info
    NTWK_EXT_NIC=eth3                    # external network trunk -> trunk 이므로 설정 불필요
    #NTWK_PRVT_NIC=                  # guest network trunk  -> trunk 이므로 설정 불필요    
    NTWK_PUB_MGMT_NIC=$CTRL_API_NIC     # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함

    #
    # compute node 01
    COM01_MGMT_IP=$CTRL_MGMT_IP         # management network ip
    COM01_MGMT_SUBNET_MASK=$CTRL_MGMT_SUBNET_MASK
        
    COM01_PUB_MGMT_IP=$CTRL_API_IP          # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함
    COM01_PUB_MGMT_SUBNET_MASK=$CTRL_API_SUBNET_MASK
    COM01_PUB_MGMT_GW=$CTRL_API_GW
    COM01_PUB_MGMT_DNS=$CTRL_API_DNS
    

    COM01_MGMT_NIC=$CTRL_MGMT_NIC       # management network ip
    COM01_PRVT_NIC=$NTWK_PRVT_NIC       # 1G NIC guest network trunk -> trunk 이므로 설정 불필요
    COM01_HYBR_NIC=eth2                 # 1G NIC hybrid networkt trunk -> trunk 이므로 설정 불필요
    COM01_PUB_MGMT_NIC=$CTRL_API_NIC     # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함

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
    printf "%-30s => %-20s :: %s\n" NTWK_PRVT_NIC          $NTWK_PRVT_NIC  "nnode guest nic"
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
    printf "%-30s => %-20s :: %s\n" COM01_PRVT_NIC         $COM01_PRVT_NIC     "cnode guest nic"          
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
	
}
