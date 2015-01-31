#!/bin/bash

echo '##########################################################################'
echo '# openstack config profile'
echo '##########################################################################'


# neutron status
# cd /etc/init.d/; for i in $( ls neutron-* ); do sudo service $i status; cd; done

#--------------------------------------------------------------------------------
# 1. nova configuration
#   nova.conf       nova-compute.conf
#   api-paste.ini   logging.conf
#   policy.json     rootwrap.conf
#--------------------------------------------------------------------------------
# process                       config file
#--------------------------------------------------------------------------------
# /usr/bin/nova-api               /etc/nova/nova.conf
#                                /etc/nova/api-paste.ini
# /usr/bin/nova-cert              /etc/nova/nova.conf
# /usr/bin/nova-conductor         /etc/nova/nova.conf
# /usr/bin/nova-consoleauth       /etc/nova/nova.conf
# /usr/bin/nova-novncproxy        /etc/nova/nova.conf
# /usr/bin/nova-scheduler         /etc/nova/nova.conf
# /usr/bin/nova-compute           /etc/nova/nova.conf
#                                 /etc/nova/nova-compute.conf
# /usr/bin/nova-novncproxy        /etc/nova/nova.conf
#--------------------------------------------------------------------------------
# /usr/sbin/libvirtd -d -l        /etc/libvirt/libvirtd.conf

#--------------------------------------------------------------------------------
# 2. glance configuration
#   glance-api.conf        glance-api-paste.ini
#   glance-registry.conf   glance-registry-paste.ini
#   policy.json
#   glance-cache.conf  glance-scrubber.conf
#--------------------------------------------------------------------------------
# process                       config file
#--------------------------------------------------------------------------------
# /usr/bin/glance-api           /etc/glance/glance-api.conf
#                               /etc/glance/glance-api-paste.ini
# /usr/bin/glance-registry      /etc/glance/glance-registry.conf
#                               /etc/glance/glance-registry-paste.ini
#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
# 3. cinder configuration
#   api-paste.ini  cinder.conf  logging.conf  policy.json  rootwrap.conf
#--------------------------------------------------------------------------------
# process                       config file
#--------------------------------------------------------------------------------
# /usr/bin/cinder-api           /etc/cinder/cinder.conf
#                               /etc/cinder/api-paste.ini
# /usr/bin/cinder-scheduler     /etc/cinder/cinder.conf
# /usr/bin/cinder-volume        /etc/cinder/cinder.conf
#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
# 4. keystone configuration
#   keystone.conf  keystone-paste.ini  logging.conf
#   policy.json    default_catalog.templates
#--------------------------------------------------------------------------------
# process                       config file
#--------------------------------------------------------------------------------
# /usr/bin/keystone-all         /etc/cinder/keystone.conf
#                               /etc/cinder/keystone-paste.ini
#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
# 5. neutron configuration
#--------------------------------------------------------------------------------
#   neutron.conf
#   api-paste.ini
#   dhcp_agent.ini
#   l3_agent.ini
#   metadata_agent.ini
#   policy.json  rootwrap.conf
#   /etc/neutron/plugins/ml2/ml2_conf.ini
#--------------------------------------------------------------------------------
# process                   config file
#--------------------------------------------------------------------------------
# neutron-server
#                           /etc/neutron/neutron.conf
#                           /etc/neutron/api-paste.ini
#                           /etc/neutron/plugins/ml2/ml2_conf.ini
#                           /etc/default/neutron-server
# neutron-plugin-openvswitch-agent
#                           /etc/neutron/neutron.conf
#                           /etc/neutron/api-paste.ini
#                           /etc/neutron/plugins/ml2/ml2_conf.ini
#                           /etc/init/neutron-plugin-openvswitch-agent.conf
# neutron-dhcp-agent
#                           /etc/neutron/neutron.conf
#                           /etc/neutron/api-paste.ini
#                           /etc/neutron/dhcp_agent.ini
# neutron-l3-agent
#                           /etc/neutron/neutron.conf
#                           /etc/neutron/api-paste.ini
#                           /etc/neutron/l3_agent.ini
# neutron-metadata-agent	/etc/neutron/neutron.conf
#                           /etc/neutron/api-paste.ini
#                           /etc/neutron/metadata_agent.ini
##--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
# 6. horizon configuration
#--------------------------------------------------------------------------------
#   /etc/apache2/apache2.conf httpd.conf  ports.conf
#   /etc/openstack-dashboard/local_settings.py   
#--------------------------------------------------------------------------------

export GLANCE_API_CONF=/etc/glance/glance-api.conf
export GLANCE_REGISTRY_CONF=/etc/glance/glance-registry.conf
export GLANCE_API_INI=/etc/glance/glance-api.conf
export GLANCE_REGISTRY_INI=/etc/glance/glance-registry.conf
export KEYSTONE_CONF=/etc/keystone/keystone.conf
export CINDER_CONF=/etc/cinder/cinder.conf
export NOVA_CONF=/etc/nova/nova.conf
export NOVA_COMPUTE_CONF=/etc/nova/nova-compute.conf
export NEUTRON_CONF=/etc/neutron/neutron.conf
export NEUTRON_DHCP_CONF=/etc/neutron/dhcp_agent.ini
export NEUTRON_L3_CONF=/etc/neutron/l3_agent.ini
export NEUTRON_META_CONF=/etc/neutron/metadata_agent.ini
export NEUTRON_ML2_CONF=/etc/neutron/plugins/ml2/ml2_conf.ini
export NEUTRON_OVS_CONF=/etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini
export MYSQL_CONF=/etc/mysql/my.cnf


alias vi_nova_conf='vim /etc/nova/nova.conf'                    # read nova.conf
alias vi_nova_compute_conf='vim /etc/nova/nova-compute.conf'    # read nova.conf
alias vi_glance_api_conf='vim /etc/glance/glance-api.conf'      # read glance-api.conf
alias vi_glance_registry_conf='vim /etc/glance/glance-registry.conf'   # read glance-registry.conf
alias vi_keystone_conf='vim /etc/keystone/keystone.conf'        # read keystone.conf
alias vi_neutron_conf='vim /etc/neutron/neutron.conf'           # read neutron.conf
alias vi_neutron_dhcp_conf='vim /etc/neutron/dhcp_agent.ini'
alias vi_neutron_l3_conf='vim /etc/neutron/l3_agent.ini'
alias vi_neutron_meta_conf='vim /etc/neutron/metadata_agent.ini'
alias vi_neutron_ml2_conf='vim /etc/neutron/plugins/ml2/ml2_conf.ini'
alias vi_neutron_ovs_conf='/etc/init/neutron-plugin-openvswitch-agent.conf'
alias vi_cinder_conf='vim /etc/cinder/cinder.conf'              # read cinder.conf



_target_dir=/root/openstack_conf

if [ -f $_target_dir ]; then
    echo
else
    mkdir $_target_dir
fi

_conf_link=${_target_dir}/glance_api_conf
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $GLANCE_API_CONF $_conf_link   
fi

_conf_link=${_target_dir}/glance_registry_conf
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $GLANCE_REGISTRY_CONF $_conf_link   
fi

_conf_link=${_target_dir}/glance_api_ini
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $GLANCE_API_INI $_conf_link   
fi

_conf_link=${_target_dir}/glance_registry_ini
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $GLANCE_REGISTRY_INI $_conf_link   
fi









_conf_link=${_target_dir}/keystone_conf
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $KEYSTONE_CONF $_conf_link   
fi

_conf_link=${_target_dir}/cinder_conf
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $CINDER_CONF $_conf_link   
fi


_conf_link=${_target_dir}/nova_conf
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NOVA_CONF $_conf_link   
fi

_conf_link=${_target_dir}/nova_compute_conf
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NOVA_COMPUTE_CONF $_conf_link   
fi

_conf_link=${_target_dir}/neutron_conf
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NEUTRON_CONF $_conf_link   
fi

_conf_link=${_target_dir}/neutron_dhcp_conf
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NEUTRON_DHCP_CONF $_conf_link   
fi

_conf_link=${_target_dir}/neutron_l3_conf
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NEUTRON_L3_CONF $_conf_link   
fi

_conf_link=${_target_dir}/neutron_meta_conf
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NEUTRON_META_CONF $_conf_link   
fi

_conf_link=${_target_dir}/neutron_ml2_conf
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NEUTRON_ML2_CONF $_conf_link   
fi

_conf_link=${_target_dir}/neutron_ovs_conf
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NEUTRON_OVS_CONF $_conf_link   
fi

_conf_link=${_target_dir}/mysql_conf
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $MYSQL_CONF $_conf_link   
fi