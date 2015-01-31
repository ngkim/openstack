#!/bin/bash

echo '##########################################################################'
echo '# openstack_src_profile'
echo '##########################################################################'

export CINDER_SRC=/usr/lib/python2.7/dist-packages/cinder
export GLANCE_SRC=/usr/lib/python2.7/dist-packages/glance
export KEYSTONE_SRC=/usr/lib/python2.7/dist-packages/keystone
export NEUTRON_SRC=/usr/lib/python2.7/dist-packages/neutron
export NOVA_SRC=/usr/lib/python2.7/dist-packages/nova
export OSLO_SRC=/usr/lib/python2.7/dist-packages/oslo



src[cinder_src]=/usr/lib/python2.7/dist-packages/cinder
src[glance_src]=/usr/lib/python2.7/dist-packages/glance
src[keystone_src]=/usr/lib/python2.7/dist-packages/keystone
src[neutron_src]=/usr/lib/python2.7/dist-packages/neutron
src[nova_src]=/usr/lib/python2.7/dist-packages/nova
src[oslo_src]=/usr/lib/python2.7/dist-packages/oslo

test() {
arr=(${src[*]})
for idx in ${!src[*]}; do
    #su $login -c "scp $httpd_conf_new ${i}:${httpd_conf_path}"
    #su $login -c "ssh $i sudo /usr/local/apache/bin/apachectl graceful"
    printf "%30s -> %s\n" $idx "$src[$idx]"
done
}

_target_dir=/root/openstack_src
if [ -f $_target_dir ]; then
    echo
else
    mkdir $_target_dir
fi
    
    
_conf_link=${_target_dir}/cinder_src
if [ -f $_conf_link ]; then
   echo ""
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $CINDER_SRC $_conf_link   
fi

_conf_link=${_target_dir}/glance_src
if [ -f $_conf_link ]; then
   echo ""
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $GLANCE_SRC $_conf_link   
fi

_conf_link=${_target_dir}/keystone_src
if [ -f $_conf_link ]; then
   echo ""
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $KEYSTONE_SRC $_conf_link   
fi

_conf_link=${_target_dir}/neutron_src
if [ -f $_conf_link ]; then
   echo ""
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NEUTRON_SRC $_conf_link   
fi

_conf_link=${_target_dir}/nova_src
if [ -f $_conf_link ]; then
   echo ""
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NOVA_SRC $_conf_link   
fi
