#!/bin/bash

# source in common env vars
source ./common_env.sh
source ./common_base.sh

echo '
################################################################################
    controller 설치용 쉘 실행 -> controller.sh
################################################################################
'

echo '
--------------------------------------------------------------------------------
    controller 서버 네트워크 환경 설정
--------------------------------------------------------------------------------'
soruce ./ctrl_nic_setting $NIC_CONF \
    $CTRL_MGMT_NIC $CTRL_MGMT_IP $CTRL_MGMT_SUBNET_MASK \
    $CTRL_API_NIC $CTRL_API_IP $CTRL_API_SUBNET_MASK \
                  $CTRL_API_GW $CTRL_API_DNS                      
                      
echo '
--------------------------------------------------------------------------------
    controller 서버에 mysql 설치
    LJG: 나중에 이중화 & 백업 고려해야 함
--------------------------------------------------------------------------------'
source ./ctrl_mysql_install.sh    
    ctrl_mysql_install

echo '
--------------------------------------------------------------------------------
    controller 서버에 keystone 설치
--------------------------------------------------------------------------------'
source ./ctrl_keystone_install.sh    
    ctrl_keystone_install
    ctrl_keystone_base_user_env_create
    ctrl_keystone_service_create
    ctrl_keystone_service_endpoint_create
    ctrl_keystone_service_account_role_create

echo '
--------------------------------------------------------------------------------
    controller 서버에 glance 설치
--------------------------------------------------------------------------------'    
source ./ctrl_glance_install.sh    
    ctrl_glance_install
    ctrl_glance_db_create
    ctrl_glance_api_registry_configure
    ctrl_glance_restart
    ctrl_glance_demo_image_create

echo '
--------------------------------------------------------------------------------
    controller 서버에 neutron(server, plugin) 설치
--------------------------------------------------------------------------------'    
source ./ctrl_neutron_install.sh    
    ctrl_neutron_server_and_plugin_install
    ctrl_neutron_db_create
    ctrl_neutron_server_configure
    ctrl_neutron_plugin_ml2_configure
    ctrl_neutron_sudoers_append
    ctrl_neutron_server_restart

echo '
--------------------------------------------------------------------------------
    controller 서버에 nova 설치
--------------------------------------------------------------------------------'
source ./ctrl_nova_install.sh    
    ctrl_nova_install
    ctrl_nova_db_create
    ctrl_nova_configure
    ctrl_nova_restart

echo '
--------------------------------------------------------------------------------
    controller 서버에 cinder 설치
--------------------------------------------------------------------------------'
source ./ctrl_cinder_install.sh    
    ctrl_cinder_install
    ctrl_cinder_db_create
    ctrl_cinder_configure
    ctrl_cinder_restart

echo '
--------------------------------------------------------------------------------
    controller 서버에 horizon 설치
--------------------------------------------------------------------------------'
source ./ctrl_horizon_install.sh 
    ctrl_horizon_install
    ctrl_horizon_configure
    ctrl_apache_configure_restart

echo '
--------------------------------------------------------------------------------
    controller 서버에 rsyslog 설정 & 재시작
--------------------------------------------------------------------------------'

sudo echo "\$ModLoad imudp" >> $RSYSLOG_CONF
sudo echo "\$UDPServerRun 5140" >> $RSYSLOG_CONF
sudo echo "\$ModLoad imtcp" >> $RSYSLOG_CONF
sudo echo "\$InputTCPServerRun 5140" >> $RSYSLOG_CONF
sudo restart rsyslog

# LJG: 이건 뭔 얘기인가? Hack: restart neutron again...
service neutron-server restart

################################################################################
# Heat
################################################################################
# sudo ./heat.sh

################################################################################
# Ceilometer
################################################################################
#sudo ./ceilometer.sh

################################################################################
# Logstash & Kibana
################################################################################
# sudo ./logstash.sh


################################################################################
# Sort out keys for root user
# sudo ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
# rm -f ~/id_rsa*
# sudo cp ~/.ssh/id_rsa ~/openstack
# sudo cp ~/.ssh/id_rsa.pub ~/openstack
# cat ~/openstack/id_rsa.pub | sudo tee -a ~/.ssh/authorized_keys 

