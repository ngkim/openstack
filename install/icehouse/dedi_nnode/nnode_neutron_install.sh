#! /bin/bash


network_neutron_install() {

    echo '
    # ------------------------------------------------------------------------------
    ### network_neutron_install() !!!
    # ------------------------------------------------------------------------------'
    
    echo "apt-get -y install \
        neutron-plugin-ml2 \
        neutron-plugin-openvswitch-agent \
        neutron-l3-agent \
        neutron-dhcp-agent"
        
    apt-get -y install \
        neutron-plugin-ml2 \
        neutron-plugin-openvswitch-agent \
        neutron-l3-agent \
        neutron-dhcp-agent \
        neutron-plugin-ryu-agent
    
    echo '>>> check result'
    echo '# ------------------------------------------------------------------------------'        
    dpkg -l | egrep "neutron-plugin-ml2|neutron-plugin-openvswitch-agent|neutron-l3-agent|neutron-dhcp-agent"
    echo '# ------------------------------------------------------------------------------'
}

network_neutron_config() {
    echo '
    # ------------------------------------------------------------------------------
    ### network_neutron_config($NEUTRON_CONF) !!!
    # ------------------------------------------------------------------------------'
   
cat > ${NEUTRON_CONF} << EOF
# ------------------------------------------------------------------------------
[DEFAULT]
verbose = True
debug = True
state_path = /var/lib/neutron
lock_path = \$state_path/lock
log_dir = /var/log/neutron
use_syslog = True
syslog_log_facility = LOG_LOCAL0

bind_host = 0.0.0.0
bind_port = 9696

# Plugin
core_plugin = ml2
service_plugins = router
allow_overlapping_ips = True

# auth
auth_strategy = keystone

# RPC configuration options. Defined in rpc __init__
# The messaging module to use, defaults to kombu.
rpc_backend = neutron.openstack.common.rpc.impl_kombu

rabbit_host = ${CONTROLLER_HOST}
rabbit_password = guest
rabbit_port = 5672
rabbit_userid = guest
rabbit_virtual_host = /
rabbit_ha_queues = false

# ============ Notification System Options =====================
notification_driver = neutron.openstack.common.notifier.rpc_notifier

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

network_neutron_l3_agent_config() {
    echo '
    # ------------------------------------------------------------------------------
    ### network_neutron_l3_agent_config($NEUTRON_L3_AGENT_INI) !!!
    # ------------------------------------------------------------------------------'

cat > ${NEUTRON_L3_AGENT_INI} << EOF
# ------------------------------------------------------------------------------
[DEFAULT]
interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
use_namespaces = True
EOF

echo '#     6-3. neutron configuration 구성(${NEUTRON_DHCP_AGENT_INI}) !!!'
cat > ${NEUTRON_DHCP_AGENT_INI} << EOF
[DEFAULT]
interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
use_namespaces = True
EOF

echo '#     6-4. neutron configuration 구성(${NEUTRON_METADATA_AGENT_INI}) !!!'
cat > ${NEUTRON_METADATA_AGENT_INI} << EOF
[DEFAULT]
auth_url = http://${CONTROLLER_HOST}:5000/v2.0
auth_region = regionOne
admin_tenant_name = service
admin_user = ${NEUTRON_SERVICE_USER}
admin_password = ${NEUTRON_SERVICE_PASS}
nova_metadata_ip = ${CONTROLLER_HOST}
metadata_proxy_shared_secret = foo
# ------------------------------------------------------------------------------
EOF

    echo '>>> check result'
    echo '# ------------------------------------------------------------------------------'
    cat $NEUTRON_L3_AGENT_INI
    echo '# ------------------------------------------------------------------------------'
}

network_neutron_plugin_ml2_config() {
    echo '
    # ------------------------------------------------------------------------------
    ### network_neutron_plugin_ml2_config($NEUTRON_PLUGIN_ML2_CONF_INI) !!!
    # ------------------------------------------------------------------------------'

cat > ${NEUTRON_PLUGIN_ML2_CONF_INI} << EOF
# ------------------------------------------------------------------------------
[ml2]
type_drivers = vlan
tenant_network_types = vlan
mechanism_drivers = openvswitch

# physnet_guest   -> guest vlan trunk network
# physnet_hybrid  -> hybrid vlan trunk network
# physnet_ext     -> external network
[ml2_type_vlan]
# ex) network_vlan_ranges = physnet_guest:2001:4000,physnet_hybrid:1:2000
network_vlan_ranges = ${PHY_PRVT_NET_RANGE},${PHY_HYBRID_NET_RANGE}

[ovs]
integration_bridge = ${LOG_INT_BR}
# guest/external network 만 매핑, hybrid network는 매핑 불필요
# ex) bridge_mappings = physnet_guest:br-guest
bridge_mappings = ${PHY_PRVT_NET}:${LOG_PRVT_BR}

[securitygroup]
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
enable_security_group = True
# ------------------------------------------------------------------------------
EOF

    echo '>>> check result'
    echo '# ------------------------------------------------------------------------------'
    cat $NEUTRON_PLUGIN_ML2_CONF_INI
    echo '# ------------------------------------------------------------------------------'
}

network_neutron_sudoers_append() {
    echo '
    # ------------------------------------------------------------------------------
    ### neutron_neutron_sudoers_append(/etc/sudoers) !!!
    # ------------------------------------------------------------------------------'
echo "
Defaults !requiretty
neutron ALL=(ALL:ALL) NOPASSWD:ALL" | tee -a /etc/sudoers

    echo '>>> check result'
    echo '# ------------------------------------------------------------------------------'
    cat /etc/sudoers
    echo '# ------------------------------------------------------------------------------'
}

network_neutron_restart() {
    echo '
    # ------------------------------------------------------------------------------
    ### network_neutron_restart() !!!
    # ------------------------------------------------------------------------------'
    
    service neutron-plugin-openvswitch-agent restart
    service neutron-dhcp-agent restart
    service neutron-l3-agent restart
    service neutron-metadata-agent restart
    
    
    echo '>>> check result'
    echo '# ------------------------------------------------------------------------------'    
    ps -ef | grep "neutron"    
    ps -ef | egrep "neutron-plugin-openvswitch-agent|neutron-dhcp-agent|neutron-l3-agent|neutron-metadata-agent"    
    echo '# ------------------------------------------------------------------------------'

}
