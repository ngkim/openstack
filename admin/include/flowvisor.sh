source "$MNG_ROOT/include/print.sh"

## MODES
DELEGATE=1
READONLY=2
READWRITE=4

fv_help() {
	ssh $FV_SERVER "fvctl --passwd-file=passwd"
}


check_fv() {
	__FV_SERVER=$*
	
	ssh $__FV_SERVER "ps ax | grep flowvisor | grep -v grep | grep -v bash"
}

check_fv_running() {
	__FV_SERVER=$1
	COUNT=$2

    if [ $COUNT -eq 1 ]; then
    	print_info flowvisor "'$__FV_SERVER' flowvisor is running."
    elif [ $COUNT -gt 1 ]; then
    	print_err flowvisor "'$__FV_SERVER' multiple instances of flowvisor is running!!!"
    else
    	print_err flowvisor "'$__FV_SERVER' flowvisor is not running!!!"
    fi
}

fv_stop() {
	__FV_SERVER=$1

	print_title_small " - stop FlowVisor "
	FV_PID=$(ssh $__FV_SERVER "ps ax | grep flowvisor | grep -v grep" | awk '/java/ {print $1; exit}')
	ssh $FV_SERVER kill -9 $FV_PID
}

count_fv_process() {
	__FV_SERVER=$1

	COUNT=$(ssh $__FV_SERVER "ps ax | grep flowvisor | grep -v grep | grep -v bash | wc -l")

	echo $COUNT
}

fv_list_slices() {
	__FV_SERVER=$1

    ssh $__FV_SERVER "fvctl --passwd-file=passwd listSlices"
}

fv_list_devices() {
	__FV_SERVER=$1
	
    ssh $__FV_SERVER "fvctl --passwd-file=passwd listDevices"
}

fv_add_slice() {
	__FV_SERVER=$1
	NOX=$2
	SLICE=$3
	SLICE_PASSWD=$4

	echo "ssh $__FV_SERVER ./bin/flowvisor.exp $SLICE $NOX $SLICE_PASSWD"
	ssh $__FV_SERVER "./bin/flowvisor.exp $SLICE $NOX $SLICE_PASSWD"
#	ssh $__FV_SERVER "fvctl --passwd-file=/home/xgist/passwd addFlowSpace all 0 any Slice:$SLICE=4"
}

fv_add_flowspace_monitor() {
	SLICE=$1
	ssh $FV_SERVER "fvctl --passwd-file=passwd addFlowSpace all 0 any Slice:$SLICE=2"
}

fv_add_flowspace() {
	IN_PORT=$1
	MAC_ADDR=$2
	SLICE=$3

    if [ -z "$4" ]; then 
        MODE=$READWRITE
    else
        MODE=$4
    fi
	ssh $FV_SERVER "fvctl --passwd-file=passwd addFlowSpace all 0 in_port=$IN_PORT,dl_src=$MAC_ADDR Slice:$SLICE=$MODE"
}

add_switch_to_flowspace() {
	SWITCH=$1
	SLICE=$2

    if [ -z "$3" ]; then 
        MODE=$READWRITE
    else
        MODE=$3
    fi
	ssh $FV_SERVER "fvctl --passwd-file=passwd addFlowSpace $SWITCH 0 any Slice:$SLICE=$MODE"
}

add_flow_to_flowspace() {
	FLOW=$1
	SLICE=$2

    if [ -z "$3" ]; then 
        MODE=$READWRITE
    else
        MODE=$3
    fi

	echo "Add $FLOW to slice:$SLICE for all switches"
	ssh $FV_SERVER "fvctl --passwd-file=passwd addFlowSpace all 0 $FLOW Slice:$SLICE=$MODE"
}

add_switchflow_to_flowspace() {
	SWITCH=$1
	FLOW=$2
	SLICE=$3

    if [ -z "$4" ]; then 
        MODE=$READWRITE
    else
        MODE=$4
    fi

    if [ -z "$5" ]; then 
        PRI=0
    else
        PRI=$5
    fi

	echo "$SLICE: Add $FLOW of $SWITCH, MODE:$MODE, PRIORITY: $PRI"
	ssh $FV_SERVER "fvctl --passwd-file=passwd addFlowSpace $SWITCH $PRI $FLOW Slice:$SLICE=$MODE"
}

fv_get_flowspace() {
	__FV_SERVER=$1
    if [ -z "$2" ]; then 
        SLICE=$SLICE
    else
        SLICE=$2
    fi

	ssh $__FV_SERVER "fvctl --passwd-file=passwd listFlowSpace | grep $SLICE="
}

# ARP
add_arp_hp() {
    SLICE=$1

    if [ -z "$2" ]; then
        MODE=$READWRITE
    else
        MODE=$2
    fi

	if [ -z "$3" ]; then
        PRI=0
    else
        PRI=$3
    fi

    add_switchflow_to_flowspace $HPGST dl_type=0x0806 $SLICE $MODE $PRI
    add_switchflow_to_flowspace $HPCNU dl_type=0x0806 $SLICE $MODE $PRI
    add_switchflow_to_flowspace $HPKST01 dl_type=0x0806 $SLICE $MODE $PRI
    add_switchflow_to_flowspace $HPKST02 dl_type=0x0806 $SLICE $MODE $PRI
    add_switchflow_to_flowspace $HPKST03 dl_type=0x0806 $SLICE $MODE $PRI
}

add_ip_192_hp() {
	SLICE=$1

    if [ -z "$2" ]; then 
        MODE=$READWRITE
    else
        MODE=$2
    fi

    if [ -z "$3" ]; then
        PRI=0
    else
        PRI=$3
    fi

    # 192.168.1.0/24 flows
    add_switchflow_to_flowspace $HPGST nw_src=192.168.1.0/24 $SLICE $MODE $PRI
    add_switchflow_to_flowspace $HPCNU nw_src=192.168.1.0/24 $SLICE $MODE $PRI
    add_switchflow_to_flowspace $HPKST01 nw_src=192.168.1.0/24 $SLICE $MODE $PRI
    add_switchflow_to_flowspace $HPKST02 nw_src=192.168.1.0/24 $SLICE $MODE $PRI
    add_switchflow_to_flowspace $HPKST03 nw_src=192.168.1.0/24 $SLICE $MODE $PRI
}

add_ip_flow_192() {
	SWITCH=$1
	SLICE=$2

    if [ -z "$3" ]; then 
        MODE=$READWRITE
    else
        MODE=$3
    fi

	if [ -z "$4" ]; then
        PRI=0
    else
        PRI=$4
    fi
    
	add_switchflow_to_flowspace $SWITCH nw_src=192.168.1.0/24 $SLICE $MODE $PRI
}

add_monitor_flows() {
	SWITCH=$1
	SLICE=$2
    MODE=$3
    PRI=$4
	echo "add_switchflow_to_flowspace $SWITCH any $SLICE $MODE $PRI"
	add_switchflow_to_flowspace $SWITCH any $SLICE $MODE $PRI
}

add_arp_192_flows() {
	SWITCH=$1
	SLICE=$2

    if [ -z "$3" ]; then 
        MODE=$READWRITE
    else
        MODE=$3
    fi

    if [ -z "$4" ]; then
        PRI=0
    else
        PRI=$4
    fi

#	echo "add_switchflow_to_flowspace $SWITCH dl_type=0x0806 $SLICE $MODE $PRI"
#add_switchflow_to_flowspace $SWITCH dl_type=0x0806 $SLICE $MODE $PRI
#add_switchflow_to_flowspace $SWITCH nw_src=192.168.1.0/24 $SLICE $MODE $PRI
#	add_switchflow_to_flowspace $SWITCH nw_src=192.168.1.0/26 $SLICE $MODE $PRI
	add_switchflow_to_flowspace $SWITCH nw_dst=192.168.1.0/24 $SLICE $MODE $PRI
#	add_switchflow_to_flowspace $SWITCH nw_dst=192.168.1.64/26 $SLICE $MODE $PRI
#	add_switchflow_to_flowspace $SWITCH nw_dst=192.168.1.128/26 $SLICE $MODE $PRI
}

add_arp_192_flows_net_26() {
	SWITCH=$1
	SLICE=$2

    if [ -z "$3" ]; then 
        MODE=$READWRITE
    else
        MODE=$3
    fi

    if [ -z "$4" ]; then
        PRI=0
    else
        PRI=$4
    fi

	echo "add_switchflow_to_flowspace $SWITCH dl_type=0x0806 $SLICE $MODE $PRI"
	add_switchflow_to_flowspace $SWITCH dl_type=0x0806 $SLICE $MODE $PRI
	add_switchflow_to_flowspace $SWITCH nw_src=192.168.1.192/26 $SLICE $MODE $PRI
}

add_nfcnu() {
	SLICE=$1

    if [ -z "$2" ]; then 
        MODE=$READWRITE
    else
        MODE=$2
    fi

    if [ -z "$3" ]; then
        PRI=0
    else
        PRI=$3
    fi

	add_switchflow_to_flowspace $NFCNU dl_type=0x0806 $SLICE $MODE $PRI
	add_switchflow_to_flowspace $NFCNU nw_src=192.168.1.0/24 $SLICE $MODE $PRI
}

add_nfgist() {
	SLICE=$1

    if [ -z "$2" ]; then 
        MODE=$READWRITE
    else
        MODE=$2
    fi

    if [ -z "$3" ]; then
        PRI=0
    else
        PRI=$3
    fi

	add_switchflow_to_flowspace $NFGST dl_type=0x0806 $SLICE $MODE $PRI
	add_switchflow_to_flowspace $NFGST nw_src=192.168.1.0/24 $SLICE $MODE $PRI
}

add_nfkhu() {
	SLICE=$1

    if [ -z "$2" ]; then 
        MODE=$READWRITE
    else
        MODE=$2
    fi

    if [ -z "$3" ]; then
        PRI=0
    else
        PRI=$3
    fi

	add_switchflow_to_flowspace $NFKHU dl_type=0x0806 $SLICE $MODE $PRI
	add_switchflow_to_flowspace $NFKHU nw_src=192.168.1.0/24 $SLICE $MODE $PRI
}

add_nfpostech() {
	SLICE=$1

    if [ -z "$2" ]; then 
        MODE=$READWRITE
    else
        MODE=$2
    fi

	if [ -z "$3" ]; then
        PRI=0
    else
        PRI=$3
    fi

	add_switchflow_to_flowspace $NFPTC dl_type=0x0806 $SLICE $MODE $PRI
	add_switchflow_to_flowspace $NFPTC nw_src=192.168.1.0/24 $SLICE $MODE $PRI
}

add_arp_flow() {
	SWITCH=$1
	SLICE=$2

    if [ -z "$3" ]; then 
        MODE=$READWRITE
    else
        MODE=$3
    fi

    if [ -z "$4" ]; then
        PRI=0
    else
        PRI=$4
    fi

	add_switchflow_to_flowspace $SWITCH dl_type=0x0806 $SLICE $MODE $PRI
}

fv_remove_flowspace() {
	FV_SERVER=$1
	SLICE=$2

	if [ -z "$3" ]; then 
        SSH_PORT=22
    else
        SSH_PORT=$3
    fi

	FS_LIST=".fslist.tmp"
	FSID_LIST=".fsidlist.tmp"

	ssh $FV_SERVER -p $SSH_PORT "fvctl --passwd-file=passwd listFlowSpace | grep $SLICE=" > $FS_LIST
	while read line; do
		fs_idx=${line##*id=[}
		fs_id=${fs_idx%%],*}
		echo "$fs_id " >> $FSID_LIST
	done < $FS_LIST

	for FS_ID in $(cat $FSID_LIST); do
		echo $FS_ID
		ssh $FV_SERVER -p $SSH_PORT "fvctl --passwd-file=passwd removeFlowSpace $FS_ID" &
	done
	rm $FSID_LIST
	sleep 5
}



