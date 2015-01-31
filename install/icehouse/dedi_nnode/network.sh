#!/bin/bash

# network.sh

# Source in common env vars
source common_env.sh
source host_base_setting.sh

echo '
################################################################################
    nnode 설치용 쉘 실행 -> network.sh
################################################################################
'

soruce ./nnode_nic_setting $NIC_CONF \
    $NTWK_MGMT_NIC $NTWK_MGMT_IP $NTWK_MGMT_SUBNET_MASK \
    $NTWK_PRVT_NIC $NTWK_EXT_NIC \
    $NTWK_PUB_MGMT_NIC $NTWK_PUB_MGMT_IP $NTWK_PUB_MGMT_SUBNET_MASK \
                      $NTWK_PUB_MGMT_GW $NTWK_PUB_MGMT_DNS
                      
echo '
################################################################################
    nnode 컴퓨터 기본환경 설정
################################################################################'

network_syscontrol_change() {

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

network_syscontrol_change

echo '
--------------------------------------------------------------------------------
    network 서버에 ovs를 설치하고 이를 이용하여 nnode ovs 환경을 생성한다.
--------------------------------------------------------------------------------'
source ./nnode_ovs_install
    network_openvswitch_install
    network_openvswitch_execute

echo '
--------------------------------------------------------------------------------
    network 서버에 neutron을 설치하고 에이전트들(l3_agent, ml2)을 설정한다.
--------------------------------------------------------------------------------'
source ./nnode_neutron_install
    network_neutron_install
    network_neutron_config
    network_neutron_l3_agent_config
    network_neutron_plugin_ml2_config
    network_neutron_sudoers_append
    network_neutron_restart
    