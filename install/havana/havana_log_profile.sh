#!/bin/bash

echo '##########################################################################'
echo '# inside .habana_log_profile'
echo '##########################################################################'

################################################################################
#
#   OpenStack Log Files
#
################################################################################
# All nodes               misc (swift, dnsmasq)   /var/log/syslog
#-------------------------------------------------------------------------------
# Cloud controller        nova-*                  /var/log/nova
#                                                               nova-api.log
#                                                               nova-cert.log
#                                                               nova-compute.log
#                                                               nova-conductor.log
#                                                               nova-consoleauth.log
#                                                               nova-manage.log
#                                                               nova-scheduler.log
# Cloud controller        glance-*                /var/log/glance
#                                                               api.log
#                                                               registry.log
# Cloud controller        cinder-*                /var/log/cinder
#                                                               cinder-api.log
#                                                               cinder-scheduler.log
#                                                               cinder-volume.log
# Cloud controller        keystone-*              /var/log/keystone
#                                                               keystone.log
# Cloud controller        neutron-*               /var/log/neutron
#                                                               dhcp-agent.log
#                                                               l3-agent.log
#                                                               metadata-agent.log
#                                                               openvswitch-agent.log
#                                                               server.log
# Cloud controller        horizon                 /var/log/apache2
#                                                               access.log
#                                                               error.log
#                                                               other_vhosts_access.log
#
# Block Storage nodes     cinder-volume           /var/log/cinder/cinder-volume.log
# Compute nodes           libvirt                 /var/log/libvirt/libvirtd.log
# Compute nodes           Console (boot up messages) for VM instances:
#                               /var/lib/nova/instances/instance-<instance id>/console.log
#-------------------------------------------------------------------------------

export NOVA_API_LOG=/var/log/nova/nova-api.log
export NOVA_SCHEDULER_LOG=/var/log/nova/nova-scheduler.log
export NOVA_CONDUCTOR_LOG=/var/log/nova/nova-conductor.log
export NOVA_COMPUTE_LOG=/var/log/nova/nova-compute.log
export NOVA_CONSOLEAUTH_LOG=/var/log/nova/nova-consoleauth.log
export NOVA_MANAGE_LOG=/var/log/nova/nova-manage.log
export NOVA_CERT_LOG=/var/log/nova/nova-cert.log

export GLANCE_API_LOG=/var/log/glance/api.log
export GLANCE_REGISTRY_LOG=/var/log/glance/registry.log

export CINDER_API_LOG=/var/log/cinder/cinder-api.log
export CINDER_SCHEDULER_LOG=/var/log/cinder/cinder-scheduler.log
export CINDER_VOLUME_LOG=/var/log/cinder/cinder-volume.log

export KEYSTONE_LOG=/var/log/keystone/keystone.log

export NEUTRON_SERVER_LOG=/var/log/neutron/server.log
export NEUTRON_DHCP_LOG=/var/log/neutron/dhcp-agent.log
export NEUTRON_L3_LOG=/var/log/neutron/l3-agent.log
export NEUTRON_METADATA_LOG=/var/log/neutron/metadata-agent.log
export NEUTRON_OVS_LOG=/var/log/neutron/openvswitch-agent.log

export HORIZON_ACCESS_LOG=/var/log/apache2/access.log
export HORIZON_ERROR_LOG=/var/log/apache2/error.log

export LIBVIRT_LOG=/var/log/libvirt/libvirtd.log

export MYSQL_LOG=/var/log/mysql/mysql.log
export MYSQL_ERROR_LOG=/var/log/mysql/error.log
export MYSQL_SLOW_QUERY=/var/log/mysql/mysql-slow.log
export MYSQL_BIN_LOG=/var/log/mysql/mysql-bin.log

alias tailf_nova_api_log='tail -f /var/log/nova/nova-api.log'
alias tailf_nova_cert_log='tail -f /var/log/nova/nova-cert.log'
alias tailf_nova_compute_log='tail -f /var/log/nova/nova-compute.log'
alias tailf_nova_conductor_log='tail -f /var/log/nova/nova-conductor.log'
alias tailf_nova_consoleauth_log='tail -f /var/log/nova/nova-consoleauth.log'
alias tailf_nova_manage_log='tail -f /var/log/nova/nova-manage.log'
alias tailf_nova_scheduler_log='tail -f /var/log/nova/nova-scheduler.log'
alias tailf_glance_api_log='tail -f /var/log/glance/api.log'
alias tailf_glance_registry_log='tail -f /var/log/glance/registry.log'
alias tailf_cinder_api_log='tail -f /var/log/cinder/cinder-api.log'
alias tailf_cinder_scheduler_log='tail -f /var/log/cinder/cinder-scheduler.log'
alias tailf_cinder_volume_log='tail -f /var/log/cinder/cinder-volume.log'
alias tailf_keystone_log='tail -f /var/log/keystone/keystone.log'
alias tailf_neutron_server_log='tail -f /var/log/neutron/server.log'
alias tailf_neutron_dhcp_log='tail -f /var/log/neutron/dhcp-agent.log'
alias tailf_neutron_l3_log='tail -f /var/log/neutron/l3-agent.log'
alias tailf_neutron_metadata_log='tail -f /var/log/neutron/metadata-agent.log'
alias tailf_neutron_openvswitch_log='tail -f /var/log/neutron/openvswitch-agent.log'
alias tailf_libvirt_log='tail -f /var/log/libvirt/libvirtd.log'
alias tailf_horizon_access_log='tail -f /var/log/apache2/access.log'
alias tailf_horizon_error_log='tail -f /var/log/apache2/error.log'

alias tail_nova_api_log='tail -n 100 /var/log/nova/nova-api.log'
alias tail_nova_cert_log='tail -n 100 /var/log/nova/nova-cert.log'
alias tail_nova_compute_log='tail -n 100 /var/log/nova/nova-compute.log'
alias tail_nova_conductor_log='tail -n 100 /var/log/nova/nova-conductor.log'
alias tail_nova_consoleauth_log='tail -n 100 /var/log/nova/nova-consoleauth.log'
alias tail_nova_manage_log='tail -n 100 /var/log/nova/nova-manage.log'
alias tail_nova_scheduler_log='tail -n 100 /var/log/nova/nova-scheduler.log'
alias tail_glance_api_log='tail -n 100 /var/log/glance/api.log'
alias tail_glance_registry_log='tail -n 100 /var/log/glance/registry.log'
alias tail_cinder_api_log='tail -n 100 /var/log/cinder/cinder-api.log'
alias tail_cinder_scheduler_log='tail -n 100 /var/log/cinder/cinder-scheduler.log'
alias tail_cinder_volume_log='tail -n 100 /var/log/cinder/cinder-volume.log'
alias tail_keystone_log='tail -n 100 /var/log/keystone/keystone.log'
alias tail_neutron_server_log='tail -n 100 /var/log/neutron/server.log'
alias tail_neutron_dhcp_log='tail -n 100 /var/log/neutron/dhcp-agent.log'
alias tail_neutron_l3_log='tail -n 100 /var/log/neutron/l3-agent.log'
alias tail_neutron_metadata_log='tail -n 100 /var/log/neutron/metadata-agent.log'
alias tail_neutron_openvswitch_log='tail -n 100 /var/log/neutron/openvswitch-agent.log'
alias tail_libvirt_log='tail -n 100 /var/log/libvirt/libvirtd.log'
alias tail_horizon_access_log='tail -n 100 /var/log/apache2/access.log'
alias tail_horizon_error_log='tail -n 100 /var/log/apache2/error.log'




_target_dir=/root/openstack/havana/log
_conf_link=${_target_dir}/nova_api_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NOVA_API_LOG $_conf_link   
fi

_conf_link=${_target_dir}/nova_scheduler_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NOVA_SCHEDULER_LOG $_conf_link   
fi

_conf_link=${_target_dir}/nova_conductor_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NOVA_CONDUCTOR_LOG $_conf_link   
fi

_conf_link=${_target_dir}/nova_compute_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NOVA_COMPUTE_LOG $_conf_link   
fi

_conf_link=${_target_dir}/nova_consoleauth_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NOVA_CONSOLEAUTH_LOG $_conf_link   
fi

_conf_link=${_target_dir}/nova_manage_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NOVA_MANAGE_LOG $_conf_link   
fi

_conf_link=${_target_dir}/nova_cert_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NOVA_CERT_LOG $_conf_link   
fi


_conf_link=${_target_dir}/glance_api_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $GLANCE_API_LOG $_conf_link   
fi

_conf_link=${_target_dir}/glance_registry_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $GLANCE_REGISTRY_LOG $_conf_link   
fi

_conf_link=${_target_dir}/cinder_api_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $CINDER_API_LOG $_conf_link   
fi

_conf_link=${_target_dir}/cinder_scheduler_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $CINDER_SCHEDULER_LOG $_conf_link   
fi

_conf_link=${_target_dir}/cinder_volume_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $CINDER_VOLUME_LOG $_conf_link   
fi

export KEYSTONE_LOG=/var/log/keystone/keystone.log

_conf_link=${_target_dir}/keystone_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $KEYSTONE_LOG $_conf_link   
fi

_conf_link=${_target_dir}/neutron_server_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NEUTRON_SERVER_LOG $_conf_link   
fi

_conf_link=${_target_dir}/neutron_dhcp_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NEUTRON_DHCP_LOG $_conf_link   
fi

_conf_link=${_target_dir}/neutron_l3_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NEUTRON_L3_LOG $_conf_link   
fi

_conf_link=${_target_dir}/neutron_metadata_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NEUTRON_METADATA_LOG $_conf_link   
fi

_conf_link=${_target_dir}/neutron_ovs_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NEUTRON_OVS_LOG $_conf_link   
fi


_conf_link=${_target_dir}/horizon_access_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $HORIZON_ACCESS_LOG $_conf_link   
fi
_conf_link=${_target_dir}/horizon_error_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $HORIZON_ERROR_LOG $_conf_link   
fi
_conf_link=${_target_dir}/libvirt_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $LIBVIRT_LOG $_conf_link   
fi


_conf_link=${_target_dir}/mysql_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $MYSQL_LOG $_conf_link   
fi

_conf_link=${_target_dir}/mysql_err_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $MYSQL_ERROR_LOG $_conf_link   
fi

_conf_link=${_target_dir}/mysql_slow_query_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $MYSQL_SLOW_QUERY $_conf_link   
fi

_conf_link=${_target_dir}/mysql_bin_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $MYSQL_BIN_LOG $_conf_link   
fi