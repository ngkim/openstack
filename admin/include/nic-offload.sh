set_nic_offload() {
	NIC=$1
	PARAM=$2
	VALUE=$3
	HOST_IP=$4
    NETNS=$5

	if [ ! -z $5 ]; then
		#echo "ip netns exec $NETNS ssh $HOST_IP ethtool -K $NIC $PARAM $VALUE"
		ip netns exec $NETNS ssh $HOST_IP ethtool -K $NIC $PARAM $VALUE
    elif [ ! -z $4 ]; then
		ssh $HOST_IP ethtool -K $NIC $PARAM $VALUE
	else
		ethtool -K $NIC $PARAM $VALUE
	fi
}

# it will return 'on' or 'off'
get_nic_offload() {
	NIC=$1
	PARAM=$2
	HOST_IP=$3
    NETNS=$4

	if [ ! -z $4 ]; then
		#echo "ip netns exec $NETNS ssh $HOST_IP ethtool -k $NIC | grep $PARAM | awk '{print $2}'"
		ip netns exec $NETNS ssh $HOST_IP ethtool -k $NIC | grep $PARAM | awk '{print $2}'
	elif [ ! -z $3 ]; then
		ssh $HOST_IP ethtool -k $NIC | grep $PARAM | awk '{print $2}'
	else
		ethtool -k $NIC | grep $PARAM | awk '{print $2}'
	fi
}

set_gro_offload() {
	NIC=$1
	STATE=$2
	HOST_IP=$3
    NETNS=$4

	set_nic_offload $NIC gro $STATE $HOST_IP $NETNS
}

set_tso_offload() {
	NIC=$1
	STATE=$2
	HOST_IP=$3
    NETNS=$4

	set_nic_offload $NIC tso $STATE $HOST_IP $NETNS
}

get_gro_offload() {
	NIC=$1
	HOST_IP=$2
    NETNS=$3

	get_nic_offload $NIC generic-receive-offload $HOST_IP $NETNS
}

get_tso_offload() {
	NIC=$1
	HOST_IP=$2
    NETNS=$3

	get_nic_offload $NIC tcp-segmentation-offload $HOST_IP $NETNS
}

get_offload() {
	PARAM=$1
	NIC=$2
	HOST_IP=$3
    NETNS=$4

	if [ $PARAM == "tso" ]; then
		get_tso_offload $NIC $HOST_IP $NETNS
	elif [ $PARAM == "gro" ]; then
		get_gro_offload $NIC $HOST_IP $NETNS
	fi
}

set_offload() {
	PARAM=$1
	VALUE=$2
	NIC=$3
	HOST_IP=$4
    NETNS=$5

	if [ $PARAM == "tso" ]; then
		set_tso_offload $NIC $VALUE $HOST_IP $NETNS
	elif [ $PARAM == "gro" ]; then
		set_gro_offload $NIC $VALUE $HOST_IP $NETNS
	fi
}
