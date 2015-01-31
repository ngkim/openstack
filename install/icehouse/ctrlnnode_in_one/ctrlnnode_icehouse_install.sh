#!/bin/bash

echo '
################################################################################
    openstack global 환경설정
################################################################################
'

source ./common_util.sh

preprocessing="
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

echo $preprocessing


echo '
--------------------------------------------------------------------------------
    openstack install topology 설정에 따른 global_env 설정
--------------------------------------------------------------------------------'
source ./ctrlnnode_topology_variable_setting.sh
    openstack_install_allinnode_env
    topology_check
    ask_continue_stop

echo '
--------------------------------------------------------------------------------
    서버 네트워크 환경 설정
        ctrlnnode_hosts_info_setting
        ctrlnnode_NIC_setting
--------------------------------------------------------------------------------'

ask_proceed_skip _answer
if [ "$_answer" = "p" ]; then
    source ./ctrlnnode_network_setting.sh
        ctrlnnode_hosts_info_setting
        ctrlnnode_NIC_setting \
    	    $CTRL_MGMT_NIC $CTRL_MGMT_HOST_IP $CTRL_MGMT_SUBNET_MASK \
    	    $CTRL_API_NIC $CTRL_API_HOST_IP $CTRL_API_SUBNET_MASK \
    	                  $CTRL_API_GW $CTRL_API_DNS \
    	    $CTRL_GUEST_NIC $CTRL_EXT_NIC 
fi

echo '
--------------------------------------------------------------------------------
    ctrlnnode_global_variable_setting 설정
--------------------------------------------------------------------------------'

source ./ctrlnnode_global_variable_setting.sh

echo '
--------------------------------------------------------------------------------
    서버 환경 설정
        server_syscontrol_change
        timezone_setting
        repository_setting
        install_base_utils
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
################################################################################
    controller 설치용 쉘 실행 -> controller.sh
################################################################################
'

echo '
--------------------------------------------------------------------------------
    controller 서버에 mysql 설치
    LJG: 나중에 이중화 & 백업 고려해야 함
--------------------------------------------------------------------------------'
ask_proceed_skip _answer
if [ "$_answer" = "p" ]; then
    source ./ctrl_mysql_install.sh
        ctrl_mysql_install
fi

echo '
--------------------------------------------------------------------------------
    controller 서버에 keystone 설치
--------------------------------------------------------------------------------'

ask_proceed_skip _answer
if [ "$_answer" = "p" ]; then
    export OS_SERVICE_TOKEN=$SERVICE_TOKEN
    export OS_SERVICE_ENDPOINT=http://${KEYSTONE_ENDPOINT}:35357/v2.0/

    unset OS_TENANT_NAME
    unset OS_USERNAME
    unset OS_PASSWORD
    unset OS_AUTH_URL
    unset OS_NO_CACHE

    source ./ctrl_keystone_install.sh
        ctrl_keystone_install
        ctrl_keystone_config
        ask_continue_stop
        ctrl_keystone_base_user_env_create
        ask_continue_stop
        ctrl_keystone_service_create
        ctrl_keystone_service_endpoint_create
        ctrl_keystone_service_account_role_create

    unset OS_SERVICE_TOKEN
    unset OS_SERVICE_ENDPOINT

cat > ~/openstack_rc <<EOF
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=ohhberry3333
export OS_AUTH_URL=http://${KEYSTONE_ENDPOINT}:5000/v2.0/
export OS_NO_CACHE=1
export OS_VOLUME_API_VERSION=2
EOF

    cat ~/openstack_rc

fi


echo '
--------------------------------------------------------------------------------
    controller 서버에 glance 설치
--------------------------------------------------------------------------------'
ask_proceed_skip _answer
if [ "$_answer" = "p" ]; then
    source ./ctrl_glance_install.sh
        ctrl_glance_install
        ctrl_glance_db_create
        ctrl_glance_api_registry_configure
        ctrl_glance_restart
        ctrl_glance_demo_image_create
fi


echo '
--------------------------------------------------------------------------------
    controller 서버에 cinder 설치
--------------------------------------------------------------------------------'
ask_proceed_skip _answer
if [ "$_answer" = "p" ]; then
    source ./ctrl_cinder_install.sh
        ctrl_cinder_install
        ctrl_cinder_db_create
        ctrl_cinder_configure
        ctrl_cinder_restart
fi

echo '
--------------------------------------------------------------------------------
    controller 서버에 horizon 설치
--------------------------------------------------------------------------------'
ask_proceed_skip _answer
if [ "$_answer" = "p" ]; then
	source ./ctrl_horizon_install.sh
	    ctrl_horizon_install
	    ctrl_horizon_configure
	    ctrl_apache_configure_restart
fi

echo '
--------------------------------------------------------------------------------
    controller 서버에 ovs 설치
--------------------------------------------------------------------------------'
ask_proceed_skip _answer
if [ "$_answer" = "p" ]; then
    source ./ctrl_ovs_install.sh
    	openvswitch_install
    	openvswitch_execute
fi


echo '
--------------------------------------------------------------------------------
    controller 서버에 neutron(server, plugin) 설치
--------------------------------------------------------------------------------'
ask_proceed_skip _answer
if [ "$_answer" = "p" ]; then
    source ./ctrl_neutron_install.sh
        ctrl_neutron_server_install
        ctrl_neutron_plugin_install
        ctrl_neutron_db_create
        ctrl_neutron_server_configure
        ctrl_neutron_plugin_ml2_configure
        ctrl_neutron_l3_agent_config
        ctrl_neutron_dhcp_agent_config
        ctrl_neutron_metadata_agent_config
        ctrl_neutron_sudoers_append
        ctrl_neutron_server_restart
fi

echo '
--------------------------------------------------------------------------------
    controller 서버에 nova 설치
--------------------------------------------------------------------------------'
ask_proceed_skip _answer
if [ "$_answer" = "p" ]; then
    source ./ctrl_nova_install.sh
        ctrl_nova_install
        ctrl_nova_db_create
        ctrl_nova_configure
        ctrl_nova_restart
fi


echo '
--------------------------------------------------------------------------------
    controller 서버에 rsyslog 설정 & 재시작
--------------------------------------------------------------------------------'

echo "\$ModLoad imudp" >> $RSYSLOG_CONF
echo "\$UDPServerRun 5140" >> $RSYSLOG_CONF
echo "\$ModLoad imtcp" >> $RSYSLOG_CONF
echo "\$InputTCPServerRun 5140" >> $RSYSLOG_CONF
restart rsyslog

# LJG: 이건 뭔 얘기인가? Hack: restart neutron again...
# service neutron-server restart
