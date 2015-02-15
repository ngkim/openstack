MODE="[INSTALL=CON/NET/COM]"

apt_get_update() {
	apt-get update
}

modify_apt_source() {
	_HOST=$1

	# change apt-source to kr.archive.ubuntu.com
	if [ -z $_HOST ]; then
    	sed -i 's/us.archive/kr.archive/g' /etc/apt/sources.list
	else
    	ssh $_HOST "sed -i 's/us.archive/kr.archive/g' /etc/apt/sources.list"
	fi
}

add_grizzly_repo() {
	print_info $MODE "Add Grizzly Repo"
	apt-get install -y ubuntu-cloud-keyring
	apt-get install -y gplhost-archive-keyring

    GRIZZLY_REPO=/etc/apt/sources.list.d/grizzly.list
    if [ ! -f $GRIZZLY_REPO ];then
		echo deb http://archive.gplhost.com/debian grizzly main > $GRIZZLY_REPO
		echo deb http://archive.gplhost.com/debian grizzly-backports main >> $GRIZZLY_REPO
	fi
}

seed_config_mysql() {
	DATABASE_PASSWORD=$1
	
    # Seed configuration with mysql password 
	# so that apt-get install doesn't prompt us for a password upon install.
    cat <<MYSQL_PRESEED | sudo debconf-set-selections
mysql-server-5.1 mysql-server/root_password password $DATABASE_PASSWORD
mysql-server-5.1 mysql-server/root_password_again password $DATABASE_PASSWORD
mysql-server-5.1 mysql-server/start_on_boot boolean true
MYSQL_PRESEED
}

install_mysql() {
	DB_PASS=$1

	print_info $MODE "Install MySQL - Setting seed configurations"
	seed_config_mysql $DB_PASS

	print_info $MODE "Install MySQL - Install packages"
	apt-get install -y mysql-server python-mysqldb

}

install_package() {
	_PKG_TITLE=$1
	_PKG_NAME=$2

	print_info $MODE "Install $_PKG_TITLE"
	apt-get install -y $_PKG_NAME
}

install_vlan() {
	print_info $MODE "Install VLAN and bridge-utils"
	apt-get install -y vlan bridge-utils
}

install_kvm() {
        print_info $MODE  "Install KVM"
        
        apt-get install -y cpu-checker kvm
        kvm-ok
}

install_libvirt() {
        print_info $MODE "Install Libvirt"
        apt-get install -y libvirt-bin pm-utils
}

install_ovs() {
	print_info $MODE "Install Open vSwitch"
	apt-get install -y openvswitch-switch openvswitch-datapath-dkms
}

install_quantum_ovs_agent() {
	print_info $MODE "Install Quantum OVS agent"
	mkdir -p /etc/quantum
	apt-get -y install quantum-plugin-openvswitch-agent
}

install_nova() {
	print_info $MODE "Install Nova components"
	apt-get install -y nova-api nova-cert novnc nova-consoleauth nova-scheduler nova-novncproxy nova-doc nova-conductor
}

install_keystone() {
	print_info $MODE "Install Keystone components"
	apt-get install -y keystone python-keystone python-keystoneclient
}

install_cinder() {
	print_info $MODE "Install Cinder components"
	apt-get install -y cinder-api cinder-scheduler cinder-volume iscsitarget open-iscsi iscsitarget-dkms
}

install_horizon() {
	print_info $MODE "Install Horizon components"
	apt-get install -y openstack-dashboard memcached
	dpkg --purge openstack-dashboard-ubuntu-theme
	
	service apache2 restart
	service memcached restart
}

install_ethtool() {
	print_info $MODE "Ethtool and Iperf"
	apt-get install -y ethtool iperf
}

install_quantum_components() {
	install_package "DHCP-agent" quantum-dhcp-agent 
	install_package "L3-agent" quantum-l3-agent 
	install_package "Metadata-agent" quantum-metadata-agent
}


