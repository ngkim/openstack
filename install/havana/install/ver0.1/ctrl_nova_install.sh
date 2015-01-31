#! /bin/bash

ctrl_nova_install() {

    echo '
    # ------------------------------------------------------------------------------
    ### ctrl_nova_install!!!
    # ------------------------------------------------------------------------------'

    echo '  5.1 nova service 설치'
    sudo apt-get -y install \
        rabbitmq-server \
        dnsmasq \
        nova-novncproxy \
        novnc \
        nova-api \
        nova-ajax-console-proxy \
        nova-cert \
        nova-conductor \
        nova-consoleauth \
        nova-doc \
        nova-scheduler \
        python-novaclient \
        nova-objectstore
    
    echo "nova sqlite db(/var/lib/nova/nova.sqlite) delete !!!"
    sudo rm /var/lib/nova/nova.sqlite
    
    echo '>>> check result------------------------------------------------------'
    dpkg -l | egrep "rabbitmq-server|dnsmasq|\
        nova-novncproxy|novnc|nova-api|nova-ajax-console-proxy|\
        nova-cert|nova-conductor|nova-consoleauth|nova-doc|nova-scheduler|\
        python-novaclient|nova-objectstore"   
    echo '# --------------------------------------------------------------------'
    
}

ctrl_nova_db_create() {

    echo '
    # ------------------------------------------------------------------------------
    ### ctrl_nova_db_create!!!
    # ------------------------------------------------------------------------------'
    
    mysql -uroot -p$MYSQL_ROOT_PASS -e 'CREATE DATABASE nova;'
    mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$MYSQL_NOVA_PASS';"
    mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$MYSQL_NOVA_PASS';"

    echo '>>> check result------------------------------------------------------'
    mysql -u root -p${MYSQL_ROOT_PASS} -h localhost -e "show databases;"    
    echo '# --------------------------------------------------------------------'
    
}



ctrl_nova_configure() {

    echo '
    # ------------------------------------------------------------------------------
    ### ctrl_nova_configure(${NOVA_CONF}) !!!
    # ------------------------------------------------------------------------------'

cp ${NOVA_CONF}{,.bak}
cat > ${NOVA_CONF} <<EOF
# ------------------------------------------------------------------------------
[DEFAULT]
dhcpbridge_flagfile=/etc/nova/nova.conf
dhcpbridge=/usr/bin/nova-dhcpbridge
logdir=/var/log/nova
state_path=/var/lib/nova
lock_path=/var/lock/nova
root_helper=sudo nova-rootwrap /etc/nova/rootwrap.conf
verbose=True
force_dhcp_release=True

use_syslog = True
syslog_log_facility = LOG_LOCAL0

api_paste_config=${NOVA_API_PASTE}
enabled_apis=ec2,osapi_compute,metadata

#Libvirt and Virtualization
libvirt_use_virtio_for_bridges=True
connection_type=libvirt
libvirt_type=kvm

#Database
sql_connection=mysql://nova:${MYSQL_NOVA_PASS}@${MYSQL_HOST}/nova

#Messaging
rabbit_host=${MYSQL_HOST}

#EC2 API Flags
ec2_host=${MYSQL_HOST}
ec2_dmz_host=${MYSQL_HOST}
ec2_private_dns_show_ip=True

#Network settings
network_api_class=nova.network.neutronv2.api.API
neutron_url=http://${CTRL_MGMT_IP}:9696
neutron_auth_strategy=keystone
neutron_admin_tenant_name=service
neutron_admin_username=neutron
neutron_admin_password=neutron
neutron_admin_auth_url=http://${CTRL_MGMT_IP}:5000/v2.0
libvirt_vif_driver=nova.virt.libvirt.vif.LibvirtHybridOVSBridgeDriver
linuxnet_interface_driver=nova.network.linux_net.LinuxOVSInterfaceDriver
#firewall_driver=nova.virt.libvirt.firewall.IptablesFirewallDriver
security_group_api=neutron
firewall_driver=nova.virt.firewall.NoopFirewallDriver

service_neutron_metadata_proxy=true
neutron_metadata_proxy_shared_secret=foo

#Metadata
metadata_host = ${MYSQL_HOST}
metadata_listen = ${MYSQL_HOST}
metadata_listen_port = 8775

#Cinder #
volume_driver=nova.volume.driver.ISCSIDriver
enabled_apis=ec2,osapi_compute,metadata
volume_api_class=nova.volume.cinder.API
iscsi_helper=tgtadm
iscsi_ip_address=${CONTROLLER_HOST}
volumes_path=/var/lib/nova/volumes

#Images
image_service=nova.image.glance.GlanceImageService
glance_api_servers=${GLANCE_HOST}:9292

#Scheduler
scheduler_default_filters=AllHostsFilter

#Auth
auth_strategy=keystone
keystone_ec2_url=http://${KEYSTONE_ENDPOINT}:5000/v2.0/ec2tokens

#NoVNC
novnc_enabled=true
novncproxy_host=${CTRL_API_IP}   # 외부접속을 허용하려면 controller public ip 사용해야 함
novncproxy_base_url=http://${CTRL_API_IP}:6080/vnc_auto.html
novncproxy_port=6080

xvpvncproxy_port=6081
xvpvncproxy_host=${CTRL_MGMT_IP}
xvpvncproxy_base_url=http://${CTRL_API_IP}:6081/console

vncserver_proxyclient_address=${CTRL_MGMT_IP}
vncserver_listen=0.0.0.0

[keystone_authtoken]
service_protocol = http
service_host = ${CTRL_MGMT_IP}
service_port = 5000
auth_host = ${CTRL_MGMT_IP}
auth_port = 35357
auth_protocol = http
auth_uri = http://${CTRL_MGMT_IP}:35357/
admin_tenant_name = ${SERVICE_TENANT}
admin_user = ${NOVA_SERVICE_USER}
admin_password = ${NOVA_SERVICE_PASS}
# ------------------------------------------------------------------------------
EOF

    echo '>>> check result
    # ------------------------------------------------------------------------------'
    cat $NOVA_CONF
    echo '
    # ------------------------------------------------------------------------------'

    sudo chmod 0640 $NOVA_CONF
    sudo chown nova:nova $NOVA_CONF

}



ctrl_nova_restart() {
    echo '
    # ------------------------------------------------------------------------------
    ### ctrl_nova_restart() !!!
    # ------------------------------------------------------------------------------'
    
    echo '  nova db 동기화'
    sudo nova-manage db sync
    
    echo '  nova 서비스 재시작'
    sudo service nova-api restart
    sudo service nova-scheduler restart
    sudo service nova-novncproxy restart
    sudo service nova-consoleauth restart
    sudo service nova-conductor restart
    sudo service nova-cert restart    
    
    echo '>>> check result -----------------------------------------------------'
    ps -ef | grep nova
    echo '# --------------------------------------------------------------------'
}