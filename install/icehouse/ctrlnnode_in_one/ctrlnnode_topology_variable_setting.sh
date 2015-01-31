#!/bin/bash

#  ctrlnnode_topology_variable_setting.sh


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

export CONTROLLER_HOST=controller
export CONTROLLER_HOST_IP=10.0.0.101

export CONTROLLER_PUBLIC_HOST=pub_ctrl
export CONTROLLER_PUBLIC_HOST_IP=211.224.204.144

export NNODE_HOST=nnode
export MNODE_HOST_IP=10.0.0.101

export SNODE_HOST=snode
export SNODE_HOST_IP=10.0.0.101

export CNODE01_HOST=cnode01
export CNODE01_HOST_IP=10.0.0.102

export CNODE02_HOST=cnode02
export CNODE02_HOST_IP=10.0.0.103

echo "
# -----------------------------------------------
# DNS Naming Variable
# ex) Hostname.POD.LOC.BUSINESS.COMPANY
#       -> cnode01.east.dj_lab.zo.kt
# -----------------------------------------------
"

DOMAIN_COMPANY=kt
DOMAIN_BUSINESS=zo                      # zero office
DOMAIN_LOC=seocho                       # host geolocation
DOMAIN_POD=pod01                        # lack name
DOMAIN_POD_HOST_CTRL=$CONTROLLER_HOST   # controller hostname
DOMAIN_POD_HOST_NET=$NNODE_HOST         # network hostname
DOMAIN_POD_HOST_BLOCK=$SNODE_HOST       # storage(block) hostname

# cnode01.east.dj_lab.zo.kt
DOMAIN_APPENDIX=${DOMAIN_POD}.${DOMAIN_LOC}.${DOMAIN_BUSINESS}.${DOMAIN_COMPANY}

echo "
# ------------------------------------------------------------------------------
#   1대의 서버에 controller 와 nnode 오픈스택 설치를 위한 nic 환경설정
# ------------------------------------------------------------------------------
# ctrlnnode_icehouse: 10G NIC 2개 1G NIC 6개
#
#   em1(1G)    -> mgmt
#   em2(1G)    -> api internet
#   em3(1G)    -> external
#   em4(1G)    -> 
#   p1p1(10G)  -> guest
# ------------------------------------------------------------------------------"

#
# controller node

CTRL_MGMT_HOST=$CONTROLLER_HOST           # management network hostname
CTRL_MGMT_HOST_IP=$CONTROLLER_HOST_IP     # management network ip
CTRL_MGMT_SUBNET_MASK=255.255.255.0

CTRL_API_HOST=$CONTROLLER_PUBLIC_HOST     # horizon api hostname
CTRL_API_HOST_IP=$CONTROLLER_PUBLIC_HOST_IP  # horizon api ip
CTRL_API_SUBNET_MASK=255.255.255.224
CTRL_API_GW=211.224.204.129
CTRL_API_DNS=8.8.8.8

CTRL_MGMT_NIC=em1                       # management network nic info
CTRL_API_NIC=em2                        # horizon api nic info
CTRL_GUEST_NIC=em3                      # guest network trunk
CTRL_EXT_NIC=em4                        # external network trunk


topology_check() {

	echo '### check result -----------------------------------------------------'

	echo ""
    echo "## MGMT INFO"
	printf "%-30s => %-20s :: %s\n" CTRL_MGMT_HOST         $CTRL_MGMT_HOST    "controller management hostname"          
	printf "%-30s => %-20s :: %s\n" CTRL_MGMT_HOST_IP      $CTRL_MGMT_HOST_IP "controller management ip"          	
	printf "%-30s => %-20s :: %s\n" CTRL_MGMT_SUBNET_MASK  $CTRL_MGMT_SUBNET_MASK "controller management ip subnet mask"

	echo ""
    echo "## API INFO"	
	printf "%-30s => %-20s :: %s\n" CTRL_API_HOST          $CTRL_API_HOST    "controller api-server hostname"         
	printf "%-30s => %-20s :: %s\n" CTRL_API_HOST_IP       $CTRL_API_HOST_IP "controller api-server ip"         	
	printf "%-30s => %-20s :: %s\n" CTRL_API_SUBNET_MASK   $CTRL_API_SUBNET_MASK "controller api-server ip subnet mask"
	printf "%-30s => %-20s :: %s\n" CTRL_API_GW            $CTRL_API_GW    "controller api-server gateway ip"
	printf "%-30s => %-20s :: %s\n" CTRL_API_DNS           $CTRL_API_DNS   "controller api-server dns ip"	
	printf ""
	       
	echo ""                                                                                                      
	echo "## NIC INFO"
	printf "%-30s => %-20s :: %s\n" CTRL_MGMT_NIC          $CTRL_MGMT_NIC   "controller management nic"
	printf "%-30s => %-20s :: %s\n" CTRL_API_NIC           $CTRL_API_NIC    "controller api-server nic"	
    printf "%-30s => %-20s :: %s\n" CTRL_GUEST_NIC         $CTRL_GUEST_NIC  "controller guest nic"
    printf "%-30s => %-20s :: %s\n" CTRL_EXT_NIC           $CTRL_EXT_NIC    "controller external nic"

	echo '# --------------------------------------------------------------------'
	echo "  이 설정이 맞지 않으면 제대로 설치가 안되니 정확하게 확인하세요 !!!!"
    echo '# --------------------------------------------------------------------'
    echo ""	    
	
}