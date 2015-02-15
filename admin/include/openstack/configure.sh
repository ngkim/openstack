
MODE="CONFIGURE"

QEMU_CONF="/etc/libvirt/qemu.conf"
LIBVIRT_CONF="/etc/libvirt/libvirtd.conf"
LIBVIRTBIN_CONF="/etc/init/libvirt-bin.conf"
LIBVIRTBIN="/etc/default/libvirt-bin"

source "$MNG_ROOT/include/openstack/keystone.sh"

configure_ntp() {
	SERVICE_HOST=$1

	print_info $MODE "Configure NTP"
        #Comment the ubuntu NTP servers
        sed -i 's/server 0.ubuntu.pool.ntp.org/#server 0.ubuntu.pool.ntp.org/g' /etc/ntp.conf
        sed -i 's/server 1.ubuntu.pool.ntp.org/#server 1.ubuntu.pool.ntp.org/g' /etc/ntp.conf
        sed -i 's/server 2.ubuntu.pool.ntp.org/#server 2.ubuntu.pool.ntp.org/g' /etc/ntp.conf
        sed -i 's/server 3.ubuntu.pool.ntp.org/#server 3.ubuntu.pool.ntp.org/g' /etc/ntp.conf
        
        #Set the compute node to follow up your conroller node
        sed -i 's/server ntp.ubuntu.com/server '$SERVICE_HOST'/g' /etc/ntp.conf

        service ntp restart
}

configure_ip_forward() {
	print_info $MODE "Enable IP_Forwarding"
	
	sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
	# To save you from rebooting, perform the following
	sysctl net.ipv4.ip_forward=1
}

configure_qemu() {
	print_info $MODE "Configure QEMU" 

cat <<EOF | sudo tee -a $QEMU_CONF
cgroup_device_acl = [
"/dev/null", "/dev/full", "/dev/zero",
"/dev/random", "/dev/urandom",
"/dev/ptmx", "/dev/kvm", "/dev/kqemu",
"/dev/rtc", "/dev/hpet","/dev/net/tun"
]
EOF
}

configure_kvm() {
	print_info $MODE "KVM Delete default virtual bridge"
	
	virsh net-destroy default
	virsh net-undefine default
}

configure_libvirt() {
	print_info $MODE "Configure LibVirt"

cat <<EOF | sudo tee -a $LIBVIRT_CONF
listen_tls = 0
listen_tcp = 1
auth_tcp = "none"
EOF

	sed -i 's/libvirtd_opts=\"-d\"/libvirtd_opts=\"-d -l\"/g' $LIBVIRTBIN_CONF
	sed -i 's/libvirtd_opts=\"-d\"/libvirtd_opts=\"-d -l\"/g' $LIBVIRTBIN
	
	print_info $MODE "Restart libvirt-bin"
	service libvirt-bin restart
}

source_test_creds() {
	_CRED=$1

	print_info $_LOG_STR "SOURCE test creds"
	source $_CRED
}

update_controller_config() {
	_CFG=$1

	sed -i 's/10.10.10.51/'$INT_CTRL_IP'/g' $_CFG
	sed -i 's/10.20.20.51/'$INT_DATA_IP'/g' $_CFG
	sed -i 's/211.224.204.141/'$EXT_CTRL_IP'/g' $_CFG

	# update quantum plugin.ini 
	if [[ $INT_DATA_IF && $NW_TYPE = "vlan" ]]; then
		sed -i 's/br-p1p1/br-'$INT_DATA_IF'/g' $_CFG
	fi
}

update_compute_config() {
	_CFG=$1

	sed -i 's/10.10.10.52/'$INT_CTRL_IP'/g' $_CFG
	sed -i 's/10.20.20.52/'$INT_DATA_IP'/g' $_CFG
	sed -i 's/211.224.204.143/'$EXT_CTRL_IP'/g' $_CFG

	sed -i 's/10.10.10.51/'$SVC_NODE_INT_IP'/g' $_CFG
	sed -i 's/211.224.204.141/'$SVC_NODE_EXT_IP'/g' $_CFG

	# update quantum plugin.ini 
	if [[ $INT_DATA_IF && $NW_TYPE = "vlan" ]]; then
		sed -i 's/br-p1p1/br-'$INT_DATA_IF'/g' $_CFG
	fi
}

copy_and_update_cfg() {
	_MODE=$1
	_SRC=$2
	_DST=$3

	cp -r $_SRC $_DST

	if [ $_MODE == "controller" ]; then
		update_controller_config $_DST
	elif [ $_MODE == "compute" ]; then
		update_compute_config $_DST
	fi
}

configure_keystone() {
	_LOG_STR="CFG-KEYSTONE"

	# copy keystone configurations
	BACKUP_DIR=$MNG_ROOT/backup/$NW_TYPE/controller

	print_info $_LOG_STR "COPY keystone configurations"
	copy_and_update_cfg controller $BACKUP_DIR/etc/keystone/keystone.conf /etc/keystone/keystone.conf
	
	print_info $_LOG_STR "RESTART keystone services"
	service keystone restart

	print_info $_LOG_STR "RUN= keystone-manage db_sync "
	keystone-manage db_sync

	# copy keystone init scripts
	KEYSTONE_SRC_DIR=$MNG_ROOT/bin/manual/keystone
	KEYSTONE_DST_DIR=$HOME/openstack
	
	mkdir -p $KEYSTONE_DST_DIR
	print_info $_LOG_STR "COPY keystone scripts"
	cp -r $KEYSTONE_SRC_DIR $KEYSTONE_DST_DIR
	update_controller_config $KEYSTONE_DST_DIR/keystone/keystone_basic.sh
	update_controller_config $KEYSTONE_DST_DIR/keystone/keystone_endpoints_basic.sh
	update_controller_config $KEYSTONE_DST_DIR/keystone/keystone.sh
	update_controller_config $KEYSTONE_DST_DIR/keystone/keystone_creds

	print_info $_LOG_STR "RUN= keystone_basic.sh"
	$KEYSTONE_DST_DIR/keystone/keystone_basic.sh

	print_info $_LOG_STR "RUN= keystone_endpoints_basic.sh"
	$KEYSTONE_DST_DIR/keystone/keystone_endpoints_basic.sh

	_CRED=$KEYSTONE_DST_DIR/keystone/keystone_creds
	source_test_creds $_CRED

	print_info $_LOG_STR "TEST= keystone user-list"
	list_users
}

configure_glance() {
	_LOG_STR="CFG-GLANCE"

	# copy glance configurations
	BACKUP_DIR=$MNG_ROOT/backup/$NW_TYPE/controller

	print_info $_LOG_STR "COPY glance configurations"
	copy_and_update_cfg controller $BACKUP_DIR/etc/glance/glance-api-paste.ini /etc/glance/glance-api-paste.ini
	copy_and_update_cfg controller $BACKUP_DIR/etc/glance/glance-registry-paste.ini  /etc/glance/glance-registry-paste.ini
	copy_and_update_cfg controller $BACKUP_DIR/etc/glance/glance-api.conf  /etc/glance/glance-api.conf
	copy_and_update_cfg controller $BACKUP_DIR/etc/glance/glance-registry.conf  /etc/glance/glance-registry.conf

	# restart glance services
	print_info $_LOG_STR "RESTART glance services"
	service glance-api restart
	service glance-registry restart	

	print_info $_LOG_STR "RUN= glance-manage db_sync "
	glance-manage db_sync

	print_info $_LOG_STR "TEST= glance image-create"
	glance image-create --name myFirstImage --is-public true --container-format bare --disk-format qcow2 --location https://launchpad.net/cirros/trunk/0.3.0/+download/cirros-0.3.0-x86_64-disk.img

	print_info $_LOG_STR "TEST= glance image-list"
	glance image-list
}

configure_ovs() {
	print_info $MODE "OVS Add br-int bridge"
	#br-int will be used for VM integration
	ovs-vsctl add-br br-int
}

configure_ovs_br_ex() {
	EXT_IF=$1

	print_info $MODE "OVS Add br-ex bridge"
	ovs-vsctl add-br br-ex
	ovs-vsctl add-port br-ex $EXT_IF
}

# Start/Stop/Restart NOVA services
restart_nova_services() {
	ACTION=$1

	print_info $_LOG_STR "$ACTION nova services"
	service dbus $ACTION
	cd /etc/init.d/; for i in $( ls nova-* ); do service $i $ACTION; done; cd -
}

configure_nova() {
	_LOG_STR="CFG-NOVA"

	BACKUP_DIR=$MNG_ROOT/backup/$NW_TYPE/controller

	print_info $_LOG_STR "COPY nova configurations"
	copy_and_update_cfg controller $BACKUP_DIR/etc/nova/api-paste.ini /etc/nova/api-paste.ini
	copy_and_update_cfg controller $BACKUP_DIR/etc/nova/nova.conf /etc/nova/nova.conf

	print_info $_LOG_STR "RUN= nova-manage db_sync "
	nova-manage db sync

	restart_nova_services "restart"

	print_info $_LOG_STR "TEST= nova-manage service list"
	nova-manage service list
}

configure_nova_compute() {
	NODE_TYPE=$1
	_LOG_STR="CFG-NOVA-COMPUTE"

	if [ -z $NODE_TYPE ]; then
		NODE_TYPE=controller
	fi

	BACKUP_DIR=$MNG_ROOT/backup/$NW_TYPE/$NODE_TYPE

	print_info $_LOG_STR "COPY nova configurations"
	copy_and_update_cfg $NODE_TYPE $BACKUP_DIR/etc/nova/api-paste.ini /etc/nova/api-paste.ini
	copy_and_update_cfg $NODE_TYPE $BACKUP_DIR/etc/nova/nova-compute.conf /etc/nova/nova-compute.conf
	copy_and_update_cfg $NODE_TYPE $BACKUP_DIR/etc/nova/nova.conf /etc/nova/nova.conf

	print_info $_LOG_STR "RESTART nova services"
	cd /etc/init.d/; for i in $( ls nova-* ); do sudo service $i restart; done; cd -

	print_info $_LOG_STR "TEST= nova-manage service list"
	nova-manage service list
}

configure_quantum_server() {
	_LOG_STR="CFG-QUANTUM-SERVER"

	BACKUP_DIR=$MNG_ROOT/backup/$NW_TYPE/controller

	print_info $_LOG_STR "COPY quantum server configurations"
	mkdir -p /etc/quantum
	mkdir -p /etc/quantum/plugins/openvswitch

	copy_and_update_cfg controller $BACKUP_DIR/etc/quantum/quantum.conf /etc/quantum/quantum.conf
	copy_and_update_cfg controller $BACKUP_DIR/etc/quantum/api-paste.ini /etc/quantum/api-paste.ini
	copy_and_update_cfg controller $BACKUP_DIR/etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini

	print_info $_LOG_STR "RESTART quantum server"
	service quantum-server restart 
}

configure_quantum_agents_of_compute() {
	NODE_TYPE=compute
	_LOG_STR="CFG-QUANTUM-AGENTS"

	BACKUP_DIR=$MNG_ROOT/backup/$NW_TYPE/$NODE_TYPE

	print_info $_LOG_STR "COPY quantum agent configurations"
	copy_and_update_cfg $NODE_TYPE $BACKUP_DIR/etc/quantum/quantum.conf /etc/quantum/quantum.conf
	copy_and_update_cfg $NODE_TYPE $BACKUP_DIR/etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini

	print_info $_LOG_STR "RESTART quantum agents"
	service quantum-plugin-openvswitch-agent restart
}

configure_quantum_agents_of_controller() {
	NODE_TYPE=controller
	_LOG_STR="CFG-QUANTUM-AGENTS"

	BACKUP_DIR=$MNG_ROOT/backup/$NW_TYPE/$NODE_TYPE

	print_info $_LOG_STR "COPY quantum agent configurations"
	copy_and_update_cfg $NODE_TYPE $BACKUP_DIR/etc/quantum/api-paste.ini /etc/quantum/api-paste.ini
	copy_and_update_cfg $NODE_TYPE $BACKUP_DIR/etc/quantum/metadata_agent.ini /etc/quantum/metadata_agent.ini
	copy_and_update_cfg $NODE_TYPE $BACKUP_DIR/etc/quantum/quantum.conf /etc/quantum/quantum.conf

	print_info $_LOG_STR "RESTART quantum agents"
	cd /etc/init.d/; for i in $( ls quantum-* ); do sudo service $i restart; done; cd -
}

configure_quantum_agents() {
	NODE_TYPE=$1

	if [ -z $NODE_TYPE ]; then
		NODE_TYPE=controller
	fi

	if [ $NODE_TYPE == "compute" ]; then
		configure_quantum_agents_of_compute
	else
		configure_quantum_agents_of_controller
	fi
}

restart_cinder_services() {
	_LOG_STR="CFG-CINDER"

	print_info $_LOG_STR "RESTART the cinder services"
	cd /etc/init.d/; for i in $( ls cinder-* ); do sudo service $i restart; done; cd -

	print_info $_LOG_STR "VERIFY if cinder services are running"
	cd /etc/init.d/; for i in $( ls cinder-* ); do sudo service $i status; done
}

configure_cinder() {
	_LOG_STR="CFG-CINDER"

	BACKUP_DIR=$MNG_ROOT/backup/$NW_TYPE/controller

	print_info $_LOG_STR "COPY cinder configurations"
	sed -i 's/false/true/g' /etc/default/iscsitarget

	print_info $_LOG_STR "RESTART iscsi services"
	service iscsitarget start
	service open-iscsi start

	print_info $_LOG_STR "COPY cinder configurations"
	copy_and_update_cfg controller $BACKUP_DIR/etc/cinder/api-paste.ini /etc/cinder/api-paste.ini
	copy_and_update_cfg controller $BACKUP_DIR/etc/cinder/cinder.conf /etc/cinder/cinder.conf

	print_info $_LOG_STR "RUN= cinder-manage db_sync "
	cinder-manage db sync

	print_info $_LOG_STR "STOP nova services before creating cinder-volumes"
	restart_nova_services stop

	print_info $_LOG_STR "To create a volumegroup and name it cinder-volumes"
	dd if=/dev/zero of=cinder-volumes bs=1 count=0 seek=2G
	losetup /dev/loop2 cinder-volumes
	
	print_info $_LOG_STR "fdisk - type in the followings: n p 1 ENTER ENTER t 8e w"
	fdisk /dev/loop2

	print_info $_LOG_STR "Proceed to create the physical volume then the volume group"
	pvcreate /dev/loop2
	vgcreate cinder-volumes /dev/loop2

	print_info $_LOG_STR "START nova services"
	restart_nova_services start

	restart_cinder_services
}

init_database() {
	_DB=$1
	_DB_USER=$_DB"User"
	_DB_USER_PASS=$_DB"Pass"

	print_info $MODE "Create database and grant user, $_DB"
	create_database $_DB $_DB_USER $_DB_USER_PASS
	grant_database_user $_DB $_DB_USER $_DB_USER_PASS
}

configure_mysql() {
	print_info $MODE "Configure mysql to accept all incoming requests:"
	sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
	service mysql restart

	init_database keystone
	init_database glance
	init_database quantum
	init_database nova
	init_database cinder
}
