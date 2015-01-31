#!/bin/bash

echo "
    ############################################################################
        전처리
    ############################################################################
    - 오픈스텍 계정 생성 : openstack/ohhberry3333
    - root 패스워드 설정
	§ ubuntu@ubuntu:~$ sudo passwd root
	§ Enter New UNIX Password :  ohhberry3333
	§ Reype New Nunix password : ohhberry3333
    - 우분투 Firewall 해제(이건 나중에 보안심의 이슈가 될 수 있슴)
	§ sudo ufw disable
    - openssh 서버 설치
	§ sudo apt-get install -y openssh-server
    - root 권한으로 외부에서 ssh 접속 허용 설정(우분투 12.04인 경우 불필요)
	  /etc/ssh/sshd_config 파일의 PermitRootLogin 설정값을? no -> yes로 변경한다.
	  service ssh restart
"

echo '
################################################################################
모든 openstack node에서 공통으로 사용되는 /etc/hosts 정보를 만들기 위한 환경설정
################################################################################
'
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

export CNODE03_HOST=cnode03
export CNODE03_HOST_IP=10.0.0.104

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
################################################################################


source ./common_util.sh


################################################################################
################################################################################
#
#   추가할 cnode 호스트 정보(여기를 수정해 주어야 함)
#
################################################################################
################################################################################

COM_MGMT_HOST=$CNODE03_HOST
COM_MGMT_IP=$CNODE03_HOST_IP
COM_MGMT_SUBNET_MASK=255.255.255.0

COM_PUB_MGMT_IP=211.224.204.141
COM_PUB_MGMT_SUBNET_MASK=255.255.255.224
COM_PUB_MGMT_GW=211.224.204.129
COM_PUB_MGMT_DNS=8.8.8.8

COM_MGMT_NIC=em1       # management network ip
COM_PUB_MGMT_NIC=em2   # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함
COM_GUEST_NIC=em3      # 10G NIC guest network trunk
COM_HYBR_NIC=em4       # 10G NIC hybrid networkt trunk


echo '### check result -----------------------------------------------------'
echo ""
echo "## CNODE INFO"
printf "%-30s => %-20s :: %s\n" COM_MGMT_NIC         $COM_MGMT_NIC     "cnode management nic"
printf "%-30s => %-20s :: %s\n" COM_GUEST_NIC         $COM_GUEST_NIC     "cnode guest nic"
printf "%-30s => %-20s :: %s\n" COM_HYBR_NIC         $COM_HYBR_NIC     "cnode hybrid nic"
printf "%-30s => %-20s :: %s\n" COM_PUB_MGMT_NIC     $COM_PUB_MGMT_NIC "cnode public nic(tmp, delete after install sw)"
echo ""
printf "%-30s => %-20s :: %s\n" COM_MGMT_HOST        $COM_MGMT_HOST "cnode management hostname"
printf "%-30s => %-20s :: %s\n" COM_MGMT_IP          $COM_MGMT_IP   "cnode management ip"
printf "%-30s => %-20s :: %s\n" COM_MGMT_SUBNET_MASK $COM_MGMT_SUBNET_MASK "cnode management ip subnet mask"
echo ""
printf "%-30s => %-20s :: %s\n" COM_PUB_MGMT_IP      $COM_PUB_MGMT_IP  "cnode public install ip(tmp, delete after install sw)"
printf "%-30s => %-20s :: %s\n" COM_PUB_MGMT_SUBNET_MASK $COM_PUB_MGMT_SUBNET_MASK "cnode public install ip subnet mask"
printf "%-30s => %-20s :: %s\n" COM_PUB_MGMT_GW      $COM_PUB_MGMT_GW  "cnode public install gateway ip"
printf "%-30s => %-20s :: %s\n" COM_PUB_MGMT_DNS     $COM_PUB_MGMT_DNS "cnode public install dns ip"

echo '# --------------------------------------------------------------------'
echo "  이 설정이 맞지 않으면 제대로 설치가 안되니 정확하게 확인하세요 !!!!"
echo '# --------------------------------------------------------------------'
echo ""

ask_continue_stop

echo '
--------------------------------------------------------------------------------
    서버 네트워크 환경 설정
        cnode_hosts_info_setting
        cnode_NIC_setting
--------------------------------------------------------------------------------'

ask_proceed_skip _answer
if [ "$_answer" = "p" ]; then
    source ./cnode_network_setting.sh
        cnode_hosts_info_setting
        cnode_NIC_setting \
    	    $COM_MGMT_NIC $COM_MGMT_IP $COM_MGMT_SUBNET_MASK \
     	    $COM_GUEST_NIC $COM_HYBR_NIC \
    	    $COM_PUB_MGMT_NIC $COM_PUB_MGMT_IP $COM_PUB_MGMT_SUBNET_MASK \
    	                  $COM_PUB_MGMT_GW $COM_PUB_MGMT_DNS

fi

echo '
--------------------------------------------------------------------------------
    cnode_global_variable_setting 설정
--------------------------------------------------------------------------------'

source ./cnode_global_variable_setting.sh

echo '
--------------------------------------------------------------------------------
    서버 환경 설정
        server_syscontrol_change
        timezone_setting
        repository_setting
--------------------------------------------------------------------------------'

ask_proceed_skip _answer
if [ "$_answer" = "p" ]; then
    source ./host_base_setting.sh
        server_syscontrol_change
        timezone_setting
        repository_setting
        install_base_utils
fi


echo '
--------------------------------------------------------------------------------
    cnode에 cli실행을 위한 openstack_rc 설정
--------------------------------------------------------------------------------'

ask_proceed_skip _answer
if [ "$_answer" = "p" ]; then

    cat > /root/openstack_rc <<EOF
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=ohhberry3333
export OS_AUTH_URL=http://${KEYSTONE_ENDPOINT}:5000/v2.0/
export OS_NO_CACHE=1
export OS_VOLUME_API_VERSION=2
EOF

    echo "cat /root/openstack_rc"
    cat /root/openstack_rc

fi

echo '
--------------------------------------------------------------------------------
    compute 서버에 openvswitch 설치 및 실행
--------------------------------------------------------------------------------'
ask_proceed_skip _answer
if [ "$_answer" = "p" ]; then
	source ./cnode_ovs_install.sh
	    compute_openvswitch_install
	    compute_openvswitch_execute
fi


echo '
--------------------------------------------------------------------------------
    compute 서버에 nova 설치 및 구성
--------------------------------------------------------------------------------'
ask_proceed_skip _answer
if [ "$_answer" = "p" ]; then
	source ./cnode_nova_install.sh
	    compute_nova_install
	    compute_nova_configure
	    compute_nova_compute_configure
	    compute_nova_restart
fi


echo '
--------------------------------------------------------------------------------
    compute 서버에 neutron 설치 및 구성
--------------------------------------------------------------------------------'
ask_proceed_skip _answer
if [ "$_answer" = "p" ]; then
	source ./cnode_neutron_install.sh
	    compute_neutron_install
	    compute_neutron_config
	    compute_neutron_plugin_ml2_config
	    compute_neutron_sudoers_append
	    compute_neutron_plugin_openvswitch_agent_restart
fi

echo '
--------------------------------------------------------------------------------
    cnode 서버 rsyslog 설정 & 재시작
--------------------------------------------------------------------------------'

echo "\$ModLoad imudp" >> $RSYSLOG_CONF
echo "\$UDPServerRun 5140" >> $RSYSLOG_CONF
echo "\$ModLoad imtcp" >> $RSYSLOG_CONF
echo "\$InputTCPServerRun 5140" >> $RSYSLOG_CONF
restart rsyslog

# LJG: 이건 뭔 얘기인가? Hack: restart neutron again...
# service neutron-server restart

echo '
--------------------------------------------------------------------------------
    추가한 cnode를 availability zone에 추가
--------------------------------------------------------------------------------'

source ~/openstack_rc

nova aggregate-add-host zo-aggr $COM_MGMT_HOST

