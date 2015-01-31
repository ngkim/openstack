#!/bin/bash

compute_neutron_install() {

    echo '
    # ------------------------------------------------------------------------------
    ### compute_neutron_install() !!!
    # ------------------------------------------------------------------------------'
  
    # Install some packages:
    echo "  -> sudo apt-get -y install neutron-plugin-openvswitch-agent"
    sudo apt-get -y install neutron-plugin-openvswitch-agent

    echo '>>> check result'
    echo '# --------------------------------------------------------------------'
    dpkg -l | egrep "neutron-plugin-openvswitch-agent"    
    echo '# --------------------------------------------------------------------'

}

compute_neutron_config() {

    echo '
    # ------------------------------------------------------------------------------
    ### compute_neutron_config($NEUTRON_CONF) !!!
    # ------------------------------------------------------------------------------'
    
    cp $NEUTRON_CONF ${NEUTRON_CONF}.bak  
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

core_plugin = neutron.plugins.openvswitch.ovs_neutron_plugin.OVSNeutronPluginV2

allow_overlapping_ips = True
notification_driver = neutron.openstack.common.notifier.rpc_notifier

rabbit_host = ${CONTROLLER_HOST}

[quotas]

[agent]
root_helper = sudo /usr/bin/neutron-rootwrap /etc/neutron/rootwrap.conf

[service_providers]
service_provider=LOADBALANCER:Haproxy:neutron.services.loadbalancer.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default
# service_provider=VPN:openswan:neutron.services.vpn.service_drivers.ipsec.IPsecVPNDriver:default

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
# ------------------------------------------------------------------------------
EOF

    echo '>>> check result -----------------------------------------------------'
    cat $NEUTRON_CONF
    echo '# ---------------------------------------------------------------------'
}


compute_neutron_plugin_ovs_config() {

    echo '
    # ------------------------------------------------------------------------------
    ### compute_neutron_plugin_ovs_config(${NEUTRON_PLUGIN_OVS_CONF_INI}) !!!
    # ------------------------------------------------------------------------------'
    if [ $NEUTRON_PLUGIN_OVS_CONF_INI ]
    then 
        cp $NEUTRON_PLUGIN_OVS_CONF_INI ${NEUTRON_PLUGIN_OVS_CONF_INI}.bak  
    fi

cat > ${NEUTRON_PLUGIN_OVS_CONF_INI} << EOF
# ------------------------------------------------------------------------------
[database]
connection = mysql://neutron:${MYSQL_NEUTRON_PASS}@${CONTROLLER_HOST}/neutron

[ovs]
tenant_network_type = vlan
integration_bridge = br-int

# network_vlan_ranges = physnet_guest:2001:4000,physnet_hybrid:1:2000,physnet_ext
network_vlan_ranges = ${PHY_PRVT_NET_RANGE},${PHY_HYBRID_NET_RANGE},${PHY_EXT_NET}

# bridge_mappings = physnet_guest:br-private,physnet_hybrid:br-hybrid,physnet_ext:br-ex
bridge_mappings = ${PHY_PRVT_NET}:${LOG_PRVT_BR},${PHY_HYBRID_NET}:${LOG_HYBRID_BR}

[securitygroup]
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
enable_security_group = True
# ------------------------------------------------------------------------------
EOF

    echo '>>> check result -----------------------------------------------------'
    cat $NEUTRON_PLUGIN_OVS_CONF_INI
    echo '# --------------------------------------------------------------------'
}

compute_neutron_plugin_openvswitch_agent_restart() {
    echo '
    # ------------------------------------------------------------------------------
    ### compute_neutron_plugin_openvswitch_agent_restart() !!!
    # ------------------------------------------------------------------------------'
    echo "    -> service neutron-plugin-openvswitch-agent restart"
    service neutron-plugin-openvswitch-agent restart
    
    echo '>>> check result -----------------------------------------------------'
    ps -ef | grep neutron-plugin-openvswitch-agent
    echo '# --------------------------------------------------------------------'
}