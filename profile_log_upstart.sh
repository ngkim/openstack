#!/bin/bash

echo '##########################################################################'
echo '# openstack log profile'
echo '##########################################################################'

################################################################################
#
#   OpenStack upstart Log Files
#
################################################################################
# root@icehouse:/var/log/upstart# ll
root@havana:/var/log/upstart# ll | more
#-rw-r-----  1 root root 103K Oct 22 15:29 cinder-api.log
#-rw-r-----  1 root root  28K Oct 22 15:29 cinder-scheduler.log
#-rw-r-----  1 root root 357K Oct 22 15:30 cinder-volume.log
#-rw-r-----  1 root root  61K Oct 22 15:29 glance-api.log
#-rw-r-----  1 root root  34K Oct 22 15:29 glance-registry.log
#-rw-r-----  1 root root 182K Oct 22 15:29 keystone.log
#-rw-r-----  1 root root  955 Oct 22 15:29 mysql.log
#-rw-r-----  1 root root 387M Oct 22 15:30 neutron-dhcp-agent.log
#-rw-r-----  1 root root  37M Oct 22 15:30 neutron-l3-agent.log
#-rw-r-----  1 root root 4.6M Oct 22 15:29 neutron-metadata-agent.log
#-rw-r-----  1 root root 2.4G Oct 22 15:30 neutron-plugin-openvswitch-agent.log
#-rw-r-----  1 root root 695M Oct 22 15:30 neutron-server.log
#-rw-r-----  1 root root  15M Oct 22 15:29 nova-api.log
#-rw-r-----  1 root root 180K Oct 22 15:30 nova-cert.log
#-rw-r-----  1 root root 310M Oct 22 15:30 nova-compute.log
#-rw-r-----  1 root root  27M Oct 22 15:30 nova-conductor.log
#-rw-r-----  1 root root 180K Oct 22 15:30 nova-consoleauth.log
#-rw-r-----  1 root root  224 Oct 22 15:29 nova-novncproxy.log
#-rw-r-----  1 root root 305K Oct 22 15:30 nova-scheduler.log
#-rw-r-----  1 root root  191 Oct 22 15:29 openvswitch-switch.log

#-rw-r-----  1 root root     43 Oct 21 17:00 console-setup.log
#-rw-r-----  1 root root     46 Oct 21 17:00 container-detect.log
#-rw-r-----  1 root root     40 Oct 21 17:00 kmod.log
#-rw-r-----  1 root root    200 Oct 21 17:00 mountall.log
#-rw-r-----  1 root root     78 Oct 21 17:00 networking.log
#-rw-r-----  1 root root    357 Oct 21 17:00 procps-virtual-filesystems.log
#-rw-r--r--  1 root root    232 Oct 22 15:55 .project
#-rw-r-----  1 root root     64 Oct 21 17:00 rsyslog.log
#-rw-r-----  1 root root    980 Oct 22 15:48 systemd-logind.log
#-rw-r-----  1 root root     69 Oct 21 17:00 ureadahead-other.log
#-rw-r-----  1 root root   1.7M Oct 22 15:56 wait-for-state-neutron-dhcp-agentneutron-ovs-cleanup.log
#-rw-r-----  1 root root   1.5M Oct 22 15:56 wait-for-state-neutron-l3-agentneutron-ovs-cleanup.log

#-rw-r-----  1 root root   49 Oct 21 17:13 network-interface-qbr154a8dba-4b.log
#-rw-r-----  1 root root   49 Oct 21 18:14 network-interface-qbr1b07d802-9f.log
#-rw-r-----  1 root root   49 Oct 21 18:08 network-interface-qbra099c4eb-7a.log
#-rw-r-----  1 root root   49 Oct 21 17:15 network-interface-qbrf3c9f9bb-56.log
#-rw-r-----  1 root root   49 Oct 21 13:36 network-interface-qg-13acf6eb-6d.log
#-rw-r-----  1 root root   49 Oct 21 12:03 network-interface-qg-50dad33d-f0.log
#-rw-r-----  1 root root   49 Oct 21 14:31 network-interface-qg-bfb642a1-66.log
#-rw-r-----  1 root root   49 Oct 21 11:00 network-interface-qg-cc869f46-00.log
#-rw-r-----  1 root root   49 Oct 21 12:00 network-interface-qg-d6e17806-17.log
#-rw-r-----  1 root root   49 Oct 21 11:57 network-interface-qg-de2063f1-3c.log
#-rw-r-----  1 root root   49 Oct 21 11:57 network-interface-qr-5c220687-5d.log
#-rw-r-----  1 root root   49 Oct 21 14:31 network-interface-qr-7b4dff1c-6c.log
#-rw-r-----  1 root root   49 Oct 21 12:03 network-interface-qr-8ef13bde-97.log
#-rw-r-----  1 root root   49 Oct 21 13:36 network-interface-qr-c553b57f-c2.log
#-rw-r-----  1 root root   49 Oct 21 11:00 network-interface-qr-dc1c8576-8c.log
#-rw-r-----  1 root root   49 Oct 21 12:00 network-interface-qr-e684ad10-c4.log
#-rw-r-----  1 root root   49 Oct 21 17:13 network-interface-qvb154a8dba-4b.log
#-rw-r-----  1 root root   49 Oct 21 18:14 network-interface-qvb1b07d802-9f.log
#-rw-r-----  1 root root   49 Oct 21 18:08 network-interface-qvba099c4eb-7a.log
#-rw-r-----  1 root root   49 Oct 21 17:15 network-interface-qvbf3c9f9bb-56.log
#-rw-r-----  1 root root   49 Oct 21 17:13 network-interface-qvo154a8dba-4b.log
#-rw-r-----  1 root root   49 Oct 21 18:14 network-interface-qvo1b07d802-9f.log
#-rw-r-----  1 root root   49 Oct 21 18:08 network-interface-qvoa099c4eb-7a.log
#-rw-r-----  1 root root   49 Oct 21 17:15 network-interface-qvof3c9f9bb-56.log
#-rw-r-----  1 root root   49 Oct 21 15:19 network-interface-tap0626a166-0b.log
#-rw-r-----  1 root root   49 Oct 21 11:25 network-interface-tap116dcf02-d9.log
#-rw-r-----  1 root root   49 Oct 21 12:01 network-interface-tap12181a1c-fc.log
#-rw-r-----  1 root root   49 Oct 21 17:13 network-interface-tap154a8dba-4b.log
#-rw-r-----  1 root root   49 Oct 21 18:14 network-interface-tap1b07d802-9f.log
#-rw-r-----  1 root root   49 Oct 21 11:59 network-interface-tap2fca166a-02.log
#-rw-r-----  1 root root   49 Oct 21 15:19 network-interface-tap35c24555-80.log
#-rw-r-----  1 root root   49 Oct 21 11:59 network-interface-tap36cade2e-f3.log
#-rw-r-----  1 root root   49 Oct 21 15:19 network-interface-tap3a4277c8-ed.log
#-rw-r-----  1 root root   49 Oct 21 12:05 network-interface-tap41f305e6-50.log
#-rw-r-----  1 root root   49 Oct 21 11:25 network-interface-tap474994c4-e8.log
#-rw-r-----  1 root root   49 Oct 21 12:01 network-interface-tap634b3547-11.log
#-rw-r-----  1 root root   49 Oct 21 12:05 network-interface-tap7562394e-14.log
#-rw-r-----  1 root root   49 Oct 21 12:05 network-interface-tap93469e4f-d9.log
#-rw-r-----  1 root root   49 Oct 21 18:08 network-interface-tapa099c4eb-7a.log
#-rw-r-----  1 root root   49 Oct 21 12:01 network-interface-tapa6e4cd45-a7.log
#-rw-r-----  1 root root   49 Oct 21 11:59 network-interface-tapb1271878-e8.log
#-rw-r-----  1 root root   49 Oct 21 11:25 network-interface-tapc19fedef-ff.log
#-rw-r-----  1 root root   49 Oct 21 17:15 network-interface-tapf3c9f9bb-56.log

export NOVA_API_LOG_UPSTART=/var/log/upstart/nova-api.log
export NOVA_CERT_LOG_UPSTART=/var/log/upstart/nova-cert.log
export NOVA_COMPUTE_LOG_UPSTART=/var/log/upstart/nova-compute.log
export NOVA_CONDUCTOR_LOG_UPSTART=/var/log/upstart/nova-conductor.log
export NOVA_CONSOLEAUTH_LOG_UPSTART=/var/log/upstart/nova-consoleauth.log
export NOVA_NOVNCPROXY_LOG_UPSTART=/var/log/upstart/nova-novncproxy.log
export NOVA_SCHEDULER_LOG_UPSTART=/var/log/upstart/nova-scheduler.log

export GLANCE_API_LOG_UPSTART=/var/log/upstart/glance-api.log
export GLANCE_REGISTRY_LOG_UPSTART=/var/log/upstart/glance-registry.log

export CINDER_API_LOG_UPSTART=/var/log/upstart/cinder-api.log
export CINDER_SCHEDULER_LOG_UPSTART=/var/log/upstart/cinder-scheduler.log
export CINDER_VOLUME_LOG_UPSTART=/var/log/upstart/cinder-volume.log

export KEYSTONE_LOG_UPSTART=/var/log/upstart/keystone.log

export NEUTRON_SERVER_LOG_UPSTART=/var/log/upstart/neutron-server.log
export NEUTRON_DHCP_LOG_UPSTART=/var/log/upstart/neutron-dhcp-agent.log
export NEUTRON_L3_LOG_UPSTART=/var/log/upstart/neutron-l3-agent.log
export NEUTRON_METADATA_LOG_UPSTART=/var/log/upstart/neutron-metadata-agent.log
export NEUTRON_OVS_LOG_UPSTART=/var/log/upstart/neutron-plugin-openvswitch-agent.log
export OPENVSWITCH_LOG_UPSTART=/var/log/upstart/openvswitch-switch.log

export MYSQL_LOG_UPSTART=/var/log/upstart/mysql.log

_target_dir=/root/openstack_upstart_log
if [ -f $_target_dir ]; then
    echo
else
    mkdir $_target_dir
fi

_conf_link=${_target_dir}/nova_api_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NOVA_API_LOG_UPSTART $_conf_link   
fi

_conf_link=${_target_dir}/nova_scheduler_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NOVA_SCHEDULER_LOG_UPSTART $_conf_link   
fi

_conf_link=${_target_dir}/nova_conductor_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NOVA_CONDUCTOR_LOG_UPSTART $_conf_link   
fi

_conf_link=${_target_dir}/nova_compute_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NOVA_COMPUTE_LOG_UPSTART $_conf_link   
fi

_conf_link=${_target_dir}/nova_consoleauth_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NOVA_CONSOLEAUTH_LOG_UPSTART $_conf_link   
fi

_conf_link=${_target_dir}/nova_cert_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NOVA_CERT_LOG_UPSTART $_conf_link   
fi


_conf_link=${_target_dir}/glance_api_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $GLANCE_API_LOG_UPSTART $_conf_link   
fi

_conf_link=${_target_dir}/glance_registry_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $GLANCE_REGISTRY_LOG_UPSTART $_conf_link   
fi

_conf_link=${_target_dir}/cinder_api_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $CINDER_API_LOG_UPSTART $_conf_link   
fi

_conf_link=${_target_dir}/cinder_scheduler_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $CINDER_SCHEDULER_LOG_UPSTART $_conf_link   
fi

_conf_link=${_target_dir}/cinder_volume_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $CINDER_VOLUME_LOG_UPSTART $_conf_link   
fi

_conf_link=${_target_dir}/keystone_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $KEYSTONE_LOG_UPSTART $_conf_link   
fi

_conf_link=${_target_dir}/neutron_server_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NEUTRON_SERVER_LOG_UPSTART $_conf_link   
fi

_conf_link=${_target_dir}/neutron_dhcp_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NEUTRON_DHCP_LOG_UPSTART $_conf_link   
fi

_conf_link=${_target_dir}/neutron_l3_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NEUTRON_L3_LOG_UPSTART $_conf_link   
fi

_conf_link=${_target_dir}/neutron_metadata_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NEUTRON_METADATA_LOG_UPSTART $_conf_link   
fi

_conf_link=${_target_dir}/neutron_ovs_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $NEUTRON_OVS_LOG_UPSTART $_conf_link   
fi

_conf_link=${_target_dir}/openvswitch_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $OPENVSWITCH_LOG_UPSTART $_conf_link   
fi


_conf_link=${_target_dir}/mysql_log
if [ -f $_conf_link ];
then
   echo "Soft Link File $_conf_link exists."
else
   echo "Soft Link File $_conf_link doesn't exists so create it"   
   ln -s $MYSQL_LOG_UPSTART $_conf_link   
fi