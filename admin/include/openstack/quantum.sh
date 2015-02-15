get_network_id() {
	_NAME=$1

	_NID=`quantum net-list | grep $_NAME | awk '{print $2}'`
	
	echo $_NID
}

get_subnet_id() {
	_NAME=$1

	_NID=`quantum subnet-list | grep $_NAME | awk '{print $2}'`
	
	echo $_NID
}

get_router_id() {
	_NAME=$1

	_RID=`quantum router-list | grep $_NAME | awk '{print $2}'`
	
	echo $_RID
}

create_tenant_network() {
	TID=$1
	NNAME=$2

	NID=$(get_network_id $NNAME)
	if [ -z $NID ]; then
		NID=`quantum net-create --tenant-id $TID $NNAME | awk '/ id / {print $4}'`
		#NID=`quantum net-create --tenant-id $TID $NNAME --provider:network_type vlan --provider:physical_network physnet1 --provider:segmentation_id 122 | awk '/ id / {print $4}'`
	fi

	echo $NID
}

create_tenant_subnet() {
	TID=$1
        SBNAME=$2
	NNAME=$3
	SBNET=$4

	SBNET_ID=$(get_subnet_id $SBNAME)
	if [ -z $SBNET_ID ]; then
		SBNET_ID=`quantum subnet-create --tenant-id $TID --name $SBNAME $NNAME $SBNET --dns-nameservers 8.8.8.8 168.126.63.1 | grep ' id ' | awk '{print $4}'`
		  # Create vlan private network
	fi

	echo $SBNET_ID
}

create_router() {
	TID=$1
	RNAME=$2

	RID=$(get_router_id $RNAME)
	if [ -z $RID ]; then
		RID=`quantum router-create --tenant-id $TID $RNAME | grep ' id ' | awk '{print $4}'`
	fi
	echo $RID
}

add_router_to_l3_agent() {
	RNAME=$1

	L3_AGENT_ID=`quantum agent-list | grep L3 | awk '{ print $2 }'`
	quantum l3-agent-router-add $L3_AGENT_ID $RNAME
}

add_router_to_subnet() {
	RID=$1
	SBNET_ID=$2

	echo "quantum router-interface-add $RID $SBNET_ID"
	quantum router-interface-add $RID $SBNET_ID
}

restart_quantum() {
	print_info $MODE "Restart all quantum services:"
	cd /etc/init.d/; for i in $( ls quantum-* ); do sudo service $i restart; done
}	

create_ext_net() {
	ADMIN_TID=$1
	EXT_NET_NAME=$2
	
	EXT_NET_ID=`quantum net-create --tenant-id $ADMIN_TID $EXT_NET_NAME --router:external=True | awk '/ id / {print $4}'`

	echo $EXT_NET_ID
}

create_floating_ip_subnet() {
	ADMIN_TID=$1
	START_IP=$2
	END_IP=$3
	EXT_GW=$4
	EXT_NET_NAME=$5
	EXT_SBNET_MASK=$6
	
	EXT_SBNET_ID=$(get_subnet_id $EXT_NET_NAME)
	if [ -z $EXT_SBNET_ID ]; then
		quantum subnet-create --tenant-id $ADMIN_TID --allocation-pool start=$START_IP,end=$END_IP --gateway $EXT_GW $EXT_NET_NAME $EXT_SBNET_MASK --enable_dhcp=False
	fi
}

set_router_gateway() {
	RID=$1
	EXT_NET_ID=$2

	quantum router-gateway-set $RID $EXT_NET_ID
}


