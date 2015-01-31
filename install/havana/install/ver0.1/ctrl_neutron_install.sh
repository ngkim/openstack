#! /bin/bash

ctrl_neutron_server_and_plugin_install() {

    echo '
    # ------------------------------------------------------------------------------
    ### ctrl_neutron_server_and_plugin_install() !!!
    # ------------------------------------------------------------------------------'

    # 
    # echo '  4.1 neutron service 설치'
    sudo apt-get -y install neutron-server neutron-plugin-ml2

    echo '>>> check result -----------------------------------------------------'    
    dpkg -l | egrep "neutron-server|neutron-plugin-ml2"
    echo '# --------------------------------------------------------------------'    
    
}

ctrl_neutron_db_create() {

    echo '
    # ------------------------------------------------------------------------------
    ### ctrl_neutron_db_create() !!!
    # ------------------------------------------------------------------------------'
    
    mysql -uroot -p$MYSQL_ROOT_PASS -e 'CREATE DATABASE neutron;'
    mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '$MYSQL_NEUTRON_PASS';"
    mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '$MYSQL_NEUTRON_PASS';"
    
    echo '>>> check result -----------------------------------------------------'    
    mysql -u root -p${MYSQL_ROOT_PASS} -h localhost -e "show databases;"
    echo '# --------------------------------------------------------------------'    
}


ctrl_neutron_server_configure() {

    echo '
    # ------------------------------------------------------------------------------
    ### ctrl_neutron_server_configure(${NEUTRON_CONF}) !!!
    # ------------------------------------------------------------------------------'
    
    SERVICE_TENANT_ID=$(keystone tenant-list | grep ${SERVICE_TENANT} | awk '{print $2}')
    NEUTRON_USER_ID=$(keystone user-list | awk '/\ neutron \ / {print $2}')
    
    #List the new user and role assigment
    keystone user-list --tenant-id $SERVICE_TENANT_ID
    keystone user-role-list --tenant-id $SERVICE_TENANT_ID --user-id $NEUTRON_USER_ID

    echo '  4.3 neutron 서버 콤포넌트 구성(/etc/neutron/neutron.conf)'

#Configure Neutron
cat > ${NEUTRON_CONF} << EOF
# ------------------------------------------------------------------------------
[DEFAULT]
verbose = True
debug = True
state_path = /var/lib/neutron
lock_path = \$state_path/lock
log_dir = /var/log/neutron

bind_host = 0.0.0.0
bind_port = 9696

#Plugin
core_plugin = ml2
service_plugins = router
allow_overlapping_ips = True

#auth
auth_strategy = keystone

#RPC configuration options. Defined in rpc __init__
#The messaging module to use, defaults to kombu.
rpc_backend = neutron.openstack.common.rpc.impl_kombu

rabbit_host = ${CONTROLLER_HOST}
rabbit_password = guest
rabbit_port = 5672
rabbit_userid = guest
rabbit_virtual_host = /
rabbit_ha_queues = false

#============ Notification System Options =====================
notification_driver = neutron.openstack.common.notifier.rpc_notifier

#======== neutron nova interactions ==========
notify_nova_on_port_status_changes = True
notify_nova_on_port_data_changes = True
nova_url = http://${CONTROLLER_HOST}:8774/v2
nova_region_name = ${REGION}
nova_admin_username = $NOVA_SERVICE_USER
nova_admin_tenant_id = $SERVICE_TENANT_ID
nova_admin_password = $NOVA_SERVICE_PASS
nova_admin_auth_url = http://${CONTROLLER_HOST}:35357/v2.0

[quotas]
#quota_driver = neutron.db.quota_db.DbQuotaDriver
#quota_items = network,subnet,port
#default_quota = -1
#quota_network = 10
#quota_subnet = 10
#quota_port = 50
#quota_security_group = 10
#quota_security_group_rule = 100
#quota_vip = 10
#quota_pool = 10
#quota_member = -1
#quota_health_monitor = -1
#quota_router = 10
#quota_floatingip = 50

[agent]
root_helper = sudo

[keystone_authtoken]
auth_host = ${CONTROLLER_HOST}
auth_port = 35357
auth_protocol = http
admin_tenant_name = ${SERVICE_TENANT}
admin_user = ${NEUTRON_SERVICE_USER}
admin_password = ${NEUTRON_SERVICE_PASS}
signing_dir = \$state_path/keystone-signing

[database]
connection = mysql://neutron:${MYSQL_NEUTRON_PASS}@${CONTROLLER_HOST}/neutron

[service_providers]
#service_provider=LOADBALANCER:Haproxy:neutron.services.loadbalancer.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default
#service_provider=VPN:openswan:neutron.services.vpn.service_drivers.ipsec.IPsecVPNDriver:default
# ------------------------------------------------------------------------------
EOF
    
    echo '>>> check result -----------------------------------------------------'    
    cat $NEUTRON_CONF
    echo '# --------------------------------------------------------------------'

}

ctrl_neutron_plugin_ml2_configure() {

    echo '
    # ------------------------------------------------------------------------------
    ### ctrl_neutron_plugin_ml2_configure(${NEUTRON_PLUGIN_OVS_CONF_INI}) !!!
    # ------------------------------------------------------------------------------'
    
#LJG: 설정은 하고 있으나 실질적으로 controller node에서는 mgmt/api network만 사용하므로 불필요
cat > ${NEUTRON_PLUGIN_OVS_CONF_INI} << EOF
# ------------------------------------------------------------------------------
[ml2]
type_drivers = vlan
tenant_network_types = vlan
mechanism_drivers = openvswitch

[ml2_type_vlan]
# ex) network_vlan_ranges = physnet_guest:2001:4000,physnet_hybrid:1:2000,physnet_ext
network_vlan_ranges = ${PHY_PRVT_NET_RANGE},${PHY_HYBRID_NET_RANGE},${PHY_EXT_NET}

[securitygroup]
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
enable_security_group = True
# ------------------------------------------------------------------------------
EOF
    echo '>>> check result -----------------------------------------------------'    
    cat $NEUTRON_PLUGIN_OVS_CONF_INI
    echo '# --------------------------------------------------------------------'

}

ctrl_neutron_sudoers_append() {
    echo '
    # ------------------------------------------------------------------------------
    ### neutron_neutron_sudoers_append(/etc/sudoers) !!!
    # ------------------------------------------------------------------------------'

echo "
Defaults !requiretty
neutron ALL=(ALL:ALL) NOPASSWD:ALL" | tee -a /etc/sudoers

    echo '>>> check result -----------------------------------------------------'
    cat /etc/sudoers
    echo '# --------------------------------------------------------------------'

}

ctrl_neutron_server_restart() {
    echo '
    # ------------------------------------------------------------------------------
    ### ctrl_neutron_server_restart() !!!
    # ------------------------------------------------------------------------------'
    echo "    -> sudo service neutron-server restart"
    sudo service neutron-server restart
    
    echo '>>> check result -----------------------------------------------------'
    ps -ef | grep neutron-server
    echo '# --------------------------------------------------------------------'
}
