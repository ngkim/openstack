#!/bin/bash

compute_neutron_install() {

    echo '
    # ------------------------------------------------------------------------------
    ### compute_neutron_install() !!!
    # ------------------------------------------------------------------------------'
  
    # Install some packages:
    echo "  -> apt-get -y install neutron-common neutron-plugin-ml2 neutron-plugin-openvswitch-agent"
    apt-get -y install neutron-common neutron-plugin-ml2 neutron-plugin-openvswitch-agent

    echo '>>> check result'
    echo '# --------------------------------------------------------------------'
    dpkg -l | grep neutron    
    echo '# --------------------------------------------------------------------'

}

compute_neutron_config() {

    echo '
    # ------------------------------------------------------------------------------
    ### compute_neutron_config($NEUTRON_CONF) !!!
    # ------------------------------------------------------------------------------'

	backup_org ${NEUTRON_CONF}
	
cat > ${NEUTRON_CONF} << EOF
# ------------------------------------------------------------------------------
[DEFAULT]
verbose=True
debug=True
use_syslog=True
syslog_log_facility=LOG_LOCAL0

state_path=/var/lib/neutron
lock_path=\$state_path/lock
log_dir=/var/log/neutron

bind_host = 0.0.0.0
bind_port = 9696

# Plugin
core_plugin = ml2
service_plugins = router
allow_overlapping_ips = True

# auth
auth_strategy=keystone

# RPC
rpc_backend=neutron.openstack.common.rpc.impl_kombu
rabbit_host=$CONTROLLER_HOST
rabbit_password=guest

# ============ Notification System Options =====================
notification_driver = neutron.openstack.common.notifier.rpc_notifier

[agent]
root_helper = sudo

[keystone_authtoken]
auth_uri=http://${CONTROLLER_HOST}:5000/
auth_host=${CONTROLLER_HOST}
auth_port=35357
auth_protocol=http

admin_tenant_name=${SERVICE_TENANT}
admin_user=${NEUTRON_SERVICE_USER}
admin_password=${NEUTRON_SERVICE_PASS}


[database]
connection = mysql://neutron:${MYSQL_NEUTRON_PASS}@${CONTROLLER_HOST}/neutron

[service_providers]
#service_provider=LOADBALANCER:Haproxy:neutron.services.loadbalancer.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default
#service_provider=VPN:openswan:neutron.services.vpn.service_drivers.ipsec.IPsecVPNDriver:default
# ------------------------------------------------------------------------------
EOF

    echo '>>> check result -----------------------------------------------------'
    cat $NEUTRON_CONF
    echo '# ---------------------------------------------------------------------'
}


compute_neutron_plugin_ml2_config() {

    echo '
    # ------------------------------------------------------------------------------
    ### compute_neutron_plugin_ml2_config($NEUTRON_PLUGIN_ML2_CONF_INI) !!!
    # ------------------------------------------------------------------------------'

	backup_org ${NEUTRON_PLUGIN_ML2_CONF_INI}
	
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
# ex) network_vlan_ranges = physnet_guest:2001:2050,physnet_hybrid:10:41
network_vlan_ranges = ${PHY_GUEST_NET_RANGE},${PHY_HYBRID_NET_RANGE}

[ovs]
integration_bridge = ${LOG_INT_BR}
# guest/hybride network 만 매핑
# ex) bridge_mappings = physnet_guest:br-guest,physnet_hybrid:br-hybrid
bridge_mappings = ${PHY_GUEST_NET}:${LOG_GUEST_BR},${PHY_HYBRID_NET}:${LOG_HYBRID_BR}

[securitygroup]
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
enable_security_group = True
# ------------------------------------------------------------------------------
EOF

    echo '>>> check result -----------------------------------------------------'
    cat $NEUTRON_PLUGIN_ML2_CONF_INI
    echo '# --------------------------------------------------------------------'
}

compute_neutron_sudoers_append() {
    echo '
    # ------------------------------------------------------------------------------
    ### compute_neutron_sudoers_append(/etc/sudoers) !!!
    # ------------------------------------------------------------------------------'

echo "
Defaults !requiretty
neutron ALL=(ALL:ALL) NOPASSWD:ALL" | tee -a /etc/sudoers

    echo '>>> check result -----------------------------------------------------'
    cat /etc/sudoers
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
    ps -ef | grep neutron
    echo '# --------------------------------------------------------------------'
}