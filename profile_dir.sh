#!/bin/bash

echo '##########################################################################'
echo '# openstack dir profile'
echo '##########################################################################'

export CINDER_DIR=/etc/cinder
export GLANCE_DIR=/etc/glance
export KEYSTONE_DIR=/etc/keystone
export NEUTRON_DIR=/etc/neutron
export NOVA_DIR=/etc/nova
export HORIZON_DIR=/etc/openstack-dashboard

_target_dir=/root/openstack_dir
if [ -f $_target_dir ]; then
    echo
else
    mkdir $_target_dir
fi

_conf_link=${_target_dir}/cinder_dir
if [ -f $_conf_link ]; then
   echo ""
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $CINDER_DIR $_conf_link   
fi

_conf_link=${_target_dir}/glance_dir
if [ -f $_conf_link ]; then
   echo ""
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $GLANCE_DIR $_conf_link   
fi

_conf_link=${_target_dir}/keystone_dir
if [ -f $_conf_link ]; then
   echo ""
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $KEYSTONE_DIR $_conf_link   
fi

_conf_link=${_target_dir}/neutron_dir
if [ -f $_conf_link ]; then
   echo ""
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NEUTRON_DIR $_conf_link   
fi

_conf_link=${_target_dir}/nova_dir
if [ -f $_conf_link ]; then
   echo ""
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NOVA_DIR $_conf_link   
fi

_conf_link=${_target_dir}/horizon_dir
if [ -f $_conf_link ]; then
   echo ""
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $HORIZON_DIR $_conf_link   
fi