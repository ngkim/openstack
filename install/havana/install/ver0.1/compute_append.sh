#!/bin/bash

# 오픈스택 변수정보 가져옴

source ./common_util.sh
source ./common_openstack_global_variable.sh

echo "
# ------------------------------------------------------------------------------
# 추가할 cnode nic 정보 설정
# ------------------------------------------------------------------------------"

# compute node

COM_MGMT_IP=10.0.0.102            
COM_MGMT_SUBNET_MASK=255.255.255.0
   
# public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함    
COM_PUB_MGMT_IP=211.224.204.157     
COM_PUB_MGMT_SUBNET_MASK=255.255.255.224
COM_PUB_MGMT_GW=211.224.204.129
COM_PUB_MGMT_DNS=8.8.8.8
    
COM_MGMT_NIC=eth0                 # management network ip        
COM_PRVT_NIC=eth4                 # 10G NIC private network trunk -> trunk 이므로 설정 불필요
COM_HYBR_NIC=eth5                 # 10G NIC hybrid networkt trunk -> trunk 이므로 설정 불필요
COM_PUB_MGMT_NIC=eth1

    

echo "
--------------------------------------------------------------------------------
    오픈스택 컴퓨트 호스트 네트워크 정보
     네트워크 설정정보를 잘 확인하세요 
--------------------------------------------------------------------------------"
printf "%30s -> %s \n" COM_MGMT_IP $COM_MGMT_IP
printf "%30s -> %s \n" COM_MGMT_SUBNET_MASK $COM_MGMT_SUBNET_MASK
printf "%s\n" "----------------------------------"
printf "%30s -> %s \n" COM_PUB_MGMT_IP $COM_PUB_MGMT_IP
printf "%30s -> %s \n" COM_PUB_MGMT_SUBNET_MASK $COM_PUB_MGMT_SUBNET_MASK
printf "%30s -> %s \n" COM_PUB_MGMT_GW $COM_PUB_MGMT_GW
printf "%30s -> %s \n" COM_PUB_MGMT_DNS $COM_PUB_MGMT_DNS
printf "%s\n" "----------------------------------"
printf "%30s -> %s \n" COM_MGMT_NIC $COM_MGMT_NIC
printf "%30s -> %s \n" COM_PRVT_NIC $COM_PRVT_NIC
printf "%30s -> %s \n" COM_HYBR_NIC $COM_HYBR_NIC
printf "%30s -> %s \n" COM_PUB_MGMT_NIC $COM_PUB_MGMT_NIC
echo "--------------------------------------------------------------------------"


ask_continue_stop
   

echo '
--------------------------------------------------------------------------------
    compute 서버에 커널 환경(네트워크 포워딩&필터) 수정
--------------------------------------------------------------------------------'
compute_syscontrol_change() {

    echo '
    # ------------------------------------------------------------------------------
    ### kernel setting change(ip_forward, rp_filter) to /etc/sysctl.conf!!!
    # ------------------------------------------------------------------------------'

    echo "
    net.ipv4.ip_forward=1
    net.ipv4.conf.all.rp_filter=0
    net.ipv4.conf.default.rp_filter=0" | tee -a /etc/sysctl.conf

    echo "  -> sudo sysctl -p"
    sudo sysctl -p

    echo '>>> check result
    # ------------------------------------------------------------------------------'
    cat /etc/sysctl.conf
    echo '
    # ------------------------------------------------------------------------------'

}

compute_syscontrol_change

ask_continue_stop

echo '
--------------------------------------------------------------------------------
    compute 서버에 utility 설치
    
    apt-get install -y ntp dstat ethtool htop ngrep ifstat sysstat
--------------------------------------------------------------------------------'

apt-get install -y ntp dstat ethtool htop ngrep ifstat sysstat

echo '>>> check result ----------------------------------------------------'
dpkg -l | egrep "ntp|dstat|ethtool|htop|ngrep|ifstat|sysstat"
echo '# --------------------------------------------------------------------'
  
echo '
--------------------------------------------------------------------------------
    compute 서버에 KVM 설치 및 실행
--------------------------------------------------------------------------------'
source ./cnode_kvm_install.sh
    compute_kvm_install

    ask_continue_stop
        
echo '
--------------------------------------------------------------------------------
    compute 서버에 openvswitch 설치 및 실행
--------------------------------------------------------------------------------'
source ./cnode_ovs_install.sh
    compute_openvswitch_install
    compute_openvswitch_execute

ask_continue_stop

echo '
--------------------------------------------------------------------------------
    compute 서버에 neutron 설치 및 구성
--------------------------------------------------------------------------------'
source ./cnode_neutron_install.sh
    compute_neutron_install
    compute_neutron_config
    compute_neutron_plugin_ovs_config
    compute_neutron_plugin_openvswitch_agent_restart

ask_continue_stop
   
echo '
--------------------------------------------------------------------------------
    compute 서버에 nova 설치 및 구성
--------------------------------------------------------------------------------'
source ./cnode_nova_install.sh
    compute_nova_install        
    compute_nova_configure
    
    compute_nova_compute_configure
    compute_nova_restart

ask_continue_stop

echo '
--------------------------------------------------------------------------------
    compute 서버를 가용성존(zero1)에 추가
--------------------------------------------------------------------------------'

# nova aggregate-create zero1 seocho.seoul.zo.kt
# nova aggregate-add-host zero1 cnode02
