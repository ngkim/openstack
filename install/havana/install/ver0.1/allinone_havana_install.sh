#!/bin/bash


echo '
################################################################################
    openstack global 환경설정
################################################################################
'

        
echo '
--------------------------------------------------------------------------------
    openstack install topology 설정에 따른 global_env 설정
--------------------------------------------------------------------------------'
source ./common_util.sh
source ./common_openstack_topology_global_env.sh

	# 다양한 NIC 타입과 OS 버전에 따라 설정을 해주어야 함.
	# 해놓고 보니 아예 /etc/network/interfaces는 수작업으로 해주는 것이 낫다는 생각이 다드네!!!!
	# 결과확인은 allinone_nic_setting.sh 를 통해 만들어지는 결과를 통해 알수 있슴.
	# LJG: west , east인 경우 hybrid nic 번호가 다름
	# east or west 식별자로 넣어야 함.

    # openstack_install_1node_env
    # openstack_install_2nodes_env
    # openstack_install_3nodes_env

echo "
--------------------------------------------------------------------------------
    서버 네트워크 환경 설정
--------------------------------------------------------------------------------"

source ./allinone_nic_setting.sh 
    all_in_one_NIC_setting \
	    $CTRL_MGMT_NIC $CTRL_MGMT_IP $CTRL_MGMT_SUBNET_MASK \
	    $CTRL_API_NIC $CTRL_API_IP $CTRL_API_SUBNET_MASK \
	                  $CTRL_API_GW $CTRL_API_DNS \
	    $NTWK_EXT_NIC $COM01_PRVT_NIC $COM01_HYBR_NIC
	    
    # /etc/init.d/networking restart 
    


echo '
--------------------------------------------------------------------------------
    common_openstack_global_variable 설정
--------------------------------------------------------------------------------'
source ./common_openstack_global_variable.sh


base_install() {
    
	echo "
# ------------------------------------------------------------------------------
# ubuntu desktop을 사용할 경우 아래 network-manager를 지워야 함.
# ------------------------------------------------------------------------------"
	apt-get purge network-manager
	
	echo "
# ------------------------------------------------------------------------------
# 우분투 레포지토리 설정 및 update !!!
# ------------------------------------------------------------------------------"
	
	if [ $UBUNTU_VER = "12.04" ]
	then
	    echo "
	    --------------------------------------------------------------------------------    
	    UBUNTU_VER = $UBUNTU_VER 
	    apt-get install -y python-software-properties
	    add-apt-repository cloud-$OPENSTACK_VER    
	    --------------------------------------------------------------------------------"
	    
	    sudo apt-get install -y python-software-properties    
	    sudo add-apt-repository -y cloud-archive:$OPENSTACK_VER
	
	else 
	    echo "
	    --------------------------------------------------------------------------------    
	    UBUNTU_VER = $UBUNTU_VER 
	    add-apt-repository cloud-$OPENSTACK_VER    
	    --------------------------------------------------------------------------------"
	    sudo add-apt-repository -y cloud-archive:$OPENSTACK_VER        
	fi
	
    apt-get update
    apt-get upgrade -y
}

# base_install

function base_configure() {

    echo "
    # ------------------------------------------------------------------------------
    #   우분투 시간대를 한국시간대에 맞추기 !!!
    # ------------------------------------------------------------------------------"

    ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

    echo "
    # ------------------------------------------------------------------------------
    #   호스트 정보 등록 in /etc/hosts !!!
    # ------------------------------------------------------------------------------"

    mv /etc/hosts /etc/hosts.old
    
cat > /etc/hosts <<EOF
# ------------------------------------------------------------------------------
${CONTROLLER_HOST} ${DOMAIN_POD_HOST_CTRL}      ${DOMAIN_POD_HOST_CTRL}.${DOMAIN_APPENDIX}
${NTWK_MGMT_IP}    ${DOMAIN_POD_HOST_NET}       ${DOMAIN_POD_HOST_NET}.${DOMAIN_APPENDIX}
${COM01_MGMT_IP}   ${DOMAIN_POD_HOST_CNODE01}   ${DOMAIN_POD_HOST_CNODE01}.${DOMAIN_APPENDIX}
# ------------------------------------------------------------------------------
EOF

    cat /etc/hosts    

echo '################################################################################'
    
}

#base_configure



# LJG: 전체 설치에서 가장 중요한 부분
function openstack_credential_prepare() {

    echo "
    # --------------------------------------------------------------------------------------------------------------
    #   *** 매우중요***
    #
    #   LJG: 오픈스택 설치와 사용을 위해서는 2개의 인증파일이 필요
    #
    #   format: 사용자명.인증방법.인증파일확장자(cred)
    #       ex) admin.token.cred -> admin 사용자가 token을 사용하여 keystone에 인증하기 위해 사용하는 파일
    #                               이는 openstack 초장기에만 사용함
    #       ex) admin.user.cred -> admin 사용자가 username/password를 사용하여 keystone에 인증하기 위해 사용하는 파일
    #                              이는 설치가 끝난후 개별사용자별로 따로 파일을 만들어서 제공해야 한다.
    #           -> jingoo.user.cred, namgon.user.cred, forbiz.user.cred
    #
    # 1. 설치단계 keystone 사용을 위한 인증파일
    #    admin.token.cred
    #    1-1. /etc/keystone/keystone.conf 파일에서 admin_token 키의 값에 원하는 값을 설정 
    #       admin_token=ohhberry3333 
    #    1-2. ~/admin.token.cred 파일을 생성하고 아래 환경변수 설정     
    #       export OS_SERVICE_TOKEN=ohhberry3333    # 이 값은 1-1에 설정된 값과 동일해야 함.
    #       export OS_SERVICE_ENDPOINT=http://controller:35357/v2.0  # mgmt ip 설정
    #
    # 2. 개별 사용자 생성후 api 사용을 위한 인증파일, 개별 사용자마다 하나씩 사용
    #    admin.user.cred, forbiz.user.cred
    #
    #       export OS_AUTH_URL=http://controller:5000/v2.0
    #       export OS_TENANT_NAME=admin
    #       export OS_USERNAME=admin
    #       export OS_PASSWORD=ohhberry3333
    # --------------------------------------------------------------------------------------------------------------
    "

    echo "
    # --------------------------------------------------------------------------
    # 처음설치할 때 사용할 admin.token.cred 파일 생성
    # token을 사용하여 bypassing the password requirement
    # keystone을 설치해서 계정을 생성한 후에는 unset 해야함
    # --------------------------------------------------------------------------
    "

    cat > ~/admin.token.cred <<EOF
# ------------------------------------------------------------------------------
export OS_SERVICE_TOKEN=$SERVICE_TOKEN
export OS_SERVICE_ENDPOINT=http://${KEYSTONE_ENDPOINT}:35357/v2.0/
# ------------------------------------------------------------------------------
EOF

    echo "
    # --------------------------------------------------------------------------
    # 사용자들이 사용하게 될 admin.user.cred 파일 생성    
    # keystone을 설치해서 계정을 생성한 후에는 admin.token.cred을 unset 하고
    # admin.user.cred을 source해서 사용해야 함.
    #
    # 이 둘을 함께 사용하지 못함, 
    # 즉 인증을 위해서 token 이나 user/pass 방식중 하나를 사용해야 하고
    # 보통 후자를 기본으로 함. 
    # --------------------------------------------------------------------------
    "
    
    cat > ~/admin.user.cred <<EOF
# ------------------------------------------------------------------------------
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=ohhberry3333
export OS_AUTH_URL=http://${KEYSTONE_ENDPOINT}:5000/v2.0/
export OS_NO_CACHE=1
# ------------------------------------------------------------------------------
EOF
        
    # Note that we are also authenticating against the Keystone admin URL, not the internal URL.
    
    echo "cat ~/admin.token.cred"
    cat ~/admin.token.cred
    
    echo "cat ~/admin.user.cred"
    cat ~/admin.user.cred     
    
}    

# openstack_credential_prepare



echo '
--------------------------------------------------------------------------------
    서버 커널 환경(네트워크 포워딩&필터) 수정
--------------------------------------------------------------------------------'
function server_syscontrol_change() {

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

# server_syscontrol_change



echo '
################################################################################
    controller 설치용 쉘 실행
################################################################################
'

                      
echo '
--------------------------------------------------------------------------------
    controller 서버에 mysql 설치
    LJG: 나중에 이중화 & 백업 고려해야 함
--------------------------------------------------------------------------------'
source ./ctrl_mysql_install.sh    
    #ctrl_mysql_uninstall
    # ctrl_mysql_install
    

source ~/admin.token.cred

echo "env | grep OS_"
env | grep OS_
                                                                                
echo '
--------------------------------------------------------------------------------
    controller 서버에 keystone 설치
--------------------------------------------------------------------------------'
source ./ctrl_keystone_install.sh
    ctrl_keystone_uninstall            

    # ctrl_keystone_install
    # ctrl_keystone_config
        
    # ctrl_keystone_base_user_env_create        
    # ctrl_keystone_service_create
    # ctrl_keystone_service_endpoint_create    
    # ctrl_keystone_service_account_role_create

unset OS_SERVICE_TOKEN
unset OS_SERVICE_ENDPOINT

source ~/admin.user.cred

echo "env | grep OS_"
env | grep OS_
              
                                          
echo '
--------------------------------------------------------------------------------
    controller 서버에 glance 설치
--------------------------------------------------------------------------------'    
source ./ctrl_glance_install.sh
    ctrl_glance_uninstall

        exit    
# ctrl_glance_install    
    # ctrl_glance_db_create
    #ctrl_glance_paste_ini_configure
    #ctrl_glance_api_registry_configure    
    #ctrl_glance_restart

    glance image-list
            
    #ctrl_glance_demo_image_create
    

exit

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


echo '
################################################################################
    network 설치용 쉘 실행 -> network.sh
################################################################################
'

echo '
--------------------------------------------------------------------------------
    network 서버에 ovs를 설치하고 이를 이용하여 nnode ovs 환경을 생성한다.
--------------------------------------------------------------------------------'
source ./nnode_ovs_install.sh
    network_openvswitch_install
    network_openvswitch_execute

echo '
--------------------------------------------------------------------------------
    network 서버에 neutron을 설치하고 에이전트들(l3_agent, ml2)을 설정한다.
--------------------------------------------------------------------------------'
source ./nnode_neutron_install.sh
    network_neutron_install
    network_neutron_config
    network_neutron_l3_agent_config
    network_neutron_plugin_ml2_config
    network_neutron_sudoers_append
    network_neutron_restart
    

echo '
################################################################################
    compute 설치용 쉘 실행 -> compute.sh
################################################################################
'

echo '
--------------------------------------------------------------------------------
    compute 서버에 openvswitch 설치 및 실행
--------------------------------------------------------------------------------'
source ./cnode_ovs_install.sh
    compute_openvswitch_install
    compute_openvswitch_install

echo '
--------------------------------------------------------------------------------
    compute 서버에 nova 설치 및 구성
--------------------------------------------------------------------------------'
source ./cnode_nova_install.sh
    compute_nova_install
    compute_nova_configure
    compute_nova_compute_configure
    compute_nova_restart

echo '
--------------------------------------------------------------------------------
    compute 서버에 neutron 설치 및 구성
--------------------------------------------------------------------------------'
source ./cnode_neutron_install.sh
    compute_neutron_install
    compute_neutron_config
    compute_neutron_plugin_ml2_config
    compute_neutron_sudoers_append
    compute_neutron_plugin_openvswitch_agent_restart