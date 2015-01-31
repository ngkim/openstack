#!/bin/bash

compute_nova_install() {

    echo '
    # ------------------------------------------------------------------------------
    ### compute_nova_install() !!!
    # ------------------------------------------------------------------------------'
  
    echo "  ->  apt-get -y install nova-compute-kvm"
    apt-get -y install nova-compute-kvm

    echo "  -> sqlite 파일(/var/lib/nova/nova.sqlite) 삭제"
    rm -f /var/lib/nova/nova.sqlite
    
    echo '>>> check result'
    echo '# --------------------------------------------------------------------'    
    echo '>> cnode nova packages install'
    dpkg -l | egrep "nova-compute-kvm"    
    echo '# --------------------------------------------------------------------'

}


compute_nova_configure() {
    echo '
    # ------------------------------------------------------------------------------
    ### compute_nova_configure(${NOVA_CONF}) !!!
    # ------------------------------------------------------------------------------'

    cp ${NOVA_CONF} ${NOVA_CONF}.bak
    
cat > ${NOVA_CONF} <<EOF
# ------------------------------------------------------------------------------
[DEFAULT]
logdir=/var/log/nova
state_path=/var/lib/nova
lock_path=/run/lock/nova
verbose=True
debug=True
api_paste_config=/etc/nova/api-paste.ini
compute_scheduler_driver=nova.scheduler.simple.SimpleScheduler
rabbit_host=${CONTROLLER_HOST}
nova_url=http://${CONTROLLER_HOST}:8774/v1.1/
root_helper=sudo nova-rootwrap /etc/nova/rootwrap.conf

# Auth
use_deprecated_auth=false
auth_strategy=keystone

# Imaging service
glance_api_servers=${CONTROLLER_HOST}:9292
image_service=nova.image.glance.GlanceImageService

# Vnc configuration
novnc_enabled=true
novncproxy_base_url=http://${VNC_HOST}:6080/vnc_auto.html
novncproxy_port=6080
vncserver_proxyclient_address=${COM_MGMT_IP}
vncserver_listen=0.0.0.0

# Network settings
network_api_class=nova.network.neutronv2.api.API
neutron_url=http://${CONTROLLER_HOST}:9696
neutron_auth_strategy=keystone
neutron_admin_tenant_name=service
neutron_admin_username=neutron
neutron_admin_password=ohhberry3333
neutron_admin_auth_url=http://${CONTROLLER_HOST}:35357/v2.0
libvirt_vif_driver=nova.virt.libvirt.vif.LibvirtHybridOVSBridgeDriver
linuxnet_interface_driver=nova.network.linux_net.LinuxOVSInterfaceDriver
#If you want Neutron + Nova Security groups
firewall_driver=nova.virt.firewall.NoopFirewallDriver
security_group_api=neutron
#If you want Nova Security groups only, comment the two lines above and uncomment line -1-.
#-1-firewall_driver=nova.virt.libvirt.firewall.IptablesFirewallDriver

#Metadata
service_neutron_metadata_proxy = True
neutron_metadata_proxy_shared_secret = helloOpenStack
metadata_host = ${CONTROLLER_HOST}
metadata_listen = 0.0.0.0
metadata_listen_port = 8775


# Compute #
compute_driver=libvirt.LibvirtDriver

# Cinder #
volume_api_class=nova.volume.cinder.API
osapi_volume_listen_port=5900
cinder_catalog_info=volume:cinder:internalURL
[DATABASE]
connection = mysql://nova:${MYSQL_NOVA_PASS}@${MYSQL_HOST}/nova
# ------------------------------------------------------------------------------
EOF

    sudo chmod 0640 $NOVA_CONF
    sudo chown nova:nova $NOVA_CONF
    
    echo '>>> check result -----------------------------------------------------'
    echo '# --------------------------------------------------------------------'
    cat $NOVA_CONF
    echo '# --------------------------------------------------------------------'
}

compute_nova_compute_configure() {

    echo '
    # ------------------------------------------------------------------------------
    ### compute_nova_compute_configure($NOVA_COMPUTE_CONF) !!!
    # ------------------------------------------------------------------------------'

    cp ${NOVA_COMPUTE_CONF} ${NOVA_COMPUTE_CONF}.bak
    
cat > ${NOVA_COMPUTE_CONF} <<EOF
# ------------------------------------------------------------------------------
[DEFAULT]
libvirt_type=kvm
compute_driver=libvirt.LibvirtDriver
# ------------------------------------------------------------------------------
EOF

    echo '>>> check result -----------------------------------------------------'
    echo '# --------------------------------------------------------------------'
    cat $NOVA_COMPUTE_CONF
    echo '# --------------------------------------------------------------------'
}


compute_nova_restart() {
    echo '
    # ------------------------------------------------------------------------------
    ### compute_nova_restart() !!!
    # ------------------------------------------------------------------------------'
    
    echo '### 9. nova service 재시작 !!!'
    # service nova-compute restart

    for P in $(ls /etc/init/nova* | cut -d'/' -f4 | cut -d'.' -f1)
    do
    	sudo stop ${P}
    	sudo start ${P}
    done

    echo '>>> check result -----------------------------------------------------'
    echo '# --------------------------------------------------------------------'
    ps -ef | grep nova
    echo '# --------------------------------------------------------------------'
    nova-manage service list
    echo '# --------------------------------------------------------------------'
    
}