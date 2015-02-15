net_int_ctrl() {
	ITF=$1
	_IP=$2
	
cat <<EOF | sudo tee -a $NW_CONF
# VM Configuration
auto $ITF
iface $ITF inet static
	address $_IP
	netmask 255.255.255.0

EOF
}

net_int_data() {
	ITF=$1
	_IP=$2

cat <<EOF | sudo tee -a $NW_CONF
#Not internet connected
auto $ITF
iface $ITF inet static
	address $_IP
	netmask 255.255.255.0

EOF
}

net_int_data_br() {
	ITF=$1
	_HOST=$2

	if [ -z $_HOST ]; then
		ovs-vsctl add-br br-$ITF
		ovs-vsctl add-port br-$ITF $ITF
		ifconfig $ITF up
	else
		ssh $_HOST ovs-vsctl add-br br-$ITF
		ssh $_HOST ovs-vsctl add-port br-$ITF $ITF
		ssh $_HOST ifconfig $ITF up
	fi
}

net_ext_ctrl() {
	ITF=$1
	_IP=$2
	_MASK=$3
	_GW=$4
	_DNS=$5

cat <<EOF | sudo tee -a $NW_CONF
# The primary network interface
auto $ITF
iface $ITF inet static
	address $_IP
	netmask $_MASK
	gateway $_GW
	# dns-* options are implemented by the resolvconf package, if installed
	dns-nameservers $_DNS

EOF
}

net_ext_data() {
	ITF=$1

cat <<EOF | sudo tee -a $NW_CONF
auto $ITF
iface $ITF inet manual
	up ifconfig \$IFACE 0.0.0.0 up
	up ip link set \$IFACE promisc on
	down ip link set \$IFACE promisc off
	down ifconfig \$IFACE down

EOF
}

#
# initialize temporal network configuration file (default: /tmp/interfaces)
#
init_net_cfg() {
	NW_CONF=$1
	if [ -z $NW_CONF ]; then
		NW_CONF=/tmp/interfaces
	fi

cat <<EOF | sudo tee $NW_CONF
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

EOF

}


