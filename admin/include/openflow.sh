source "$MNG_ROOT/include/util.sh"

run_translate() {
	NOX_SERVER=$1
	LOG=$2
	ssh $NOX_SERVER "python Translate.py"
}

kill_translate() {
	NOX_SERVER=$1
	TRNS_PORT=$2

	TRNS_PID=$(ssh $NOX_SERVER "ps ax | grep Translate | grep $TRNS_PORT | grep -v grep"  | awk '{print $1; exit}')

	ssh $NOX kill -9 $TRNS_PID
}

run_auto_translate() {
	NOX_SERVER=$1
	TRNS_PORT=$2

	ssh $NOX_SERVER "sh AutoTranslate_$TRNS_PORT.sh"
}

check_auto_translate() {
	NOX_SERVER=$1
	TRNS_PORT=$2

	ssh $NOX_SERVER "ps ax | grep AutoTranslate | grep $TRNS_PORT | grep -v grep"
}

count_auto_translate() {
	NOX_SERVER=$1
	TRNS_PORT=$2

	ret=$(ssh $NOX_SERVER "ps ax | grep AutoTranslate | grep $TRNS_PORT | grep -v grep" | wc -l )
	echo $ret
}

kill_auto_translate() {
	NOX_SERVER=$1
	TRNS_PORT=$2

	AUTO_TRNS_PID=$(ssh $NOX_SERVER "ps ax | grep AutoTranslate | grep $TRNS_PORT | grep -v grep"  | awk '{print $1; exit}')

	ssh $NOX_SERVER kill -9 $AUTO_TRNS_PID
}

check_nox_and_fv() {
	NOX_SERVER=$1
	FV_SERVER=$2

	print_title_small " - NOX and FlowVisor processes"
	ssh $NOX_SERVER "ps ax | grep nox | grep -v grep"
	ssh $FV_SERVER "ps ax | grep flowvisor | grep -v grep"
}

check_nox() {
	NOX_SERVER=$1

	print_title_small " - NOX processes"
	ssh $NOX_SERVER "ps ax | grep nox | grep -v bash | grep -v grep"
}

check_nox_with_json() {
	NOX_SERVER=$1
	JSON_PORT=$2

	ssh $NOX_SERVER "ps ax | grep nox | grep $JSON_PORT | grep -v bash | grep -v grep"
}

count_nox_with_json() {
	NOX_SERVER=$1
	JSON_PORT=$2

	ret=$(ssh $NOX_SERVER "ps ax | grep nox | grep $JSON_PORT | grep -v bash | grep -v grep" | wc -l)
	echo $ret
}

check_nox_running() {
	COUNT=$1
    if [ $COUNT -eq 1 ]; then
    	print_info nox "nox is running."
    elif [ $COUNT -gt 1 ]; then
    	print_err nox "multiple instances of nox is running!!!"
		HALT=1
    else
    	print_err nox "nox is not running!!!"
		HALT=1
    fi
}

run_nox_with_json() {
	NOX_SERVER=$1
	TRNS_PORT=$2
	NOX_APP=$3

	echo "Executing: ssh $NOX_SERVER \"./nox_$TRNS_PORT.sh $NOX_APP\""
	ssh $NOX_SERVER "./nox_$TRNS_PORT.sh $NOX_APP"
}

get_fv_slices() {
	FV_SERVER=$1

	print_title_small " - List of Slices"
	ssh $FV_SERVER "fvctl --passwd-file=passwd listSlices"
}

get_fv_flowspaces() {
	FV_SERVER=$1

	if [ -z "$2" ]; then 
        SSH_PORT=22
    else
        SSH_PORT=$2
    fi


	print_title_small " - List of FlowSpaces "
	ssh $FV_SERVER -p $SSH_PORT "fvctl --passwd-file=passwd listFlowSpace"
}

stop_nox() {
	NOX_SERVER=$1

	print_title_small " - stop NOX "
	ssh $NOX_SERVER "killall -9 lt-nox_core"
}

fv_delete_slice() {
	FV_SERVER=$1
	SLICE=$2

	print_title_small " - remove FlowSpace and delete Slice: $SLICE"
	ssh $FV_SERVER "fvctl --passwd-file=passwd deleteSlice $SLICE"
}

add_flow_simple() {
	NW_SRC=$1
	NW_DST=$2
	IN_PORT=$3
	OUT_PORT=$4
	DATAPATH=$5

	#echo "NW_SRC = $NW_SRC"
	#echo "NW_DST = $NW_DST"
	#echo "IN_PORT = $IN_PORT"
	#echo "OUT_PORT = $OUT_PORT"
	#echo "DATAPATH = $DATAPATH"

	dpctl add-flow $DATAPATH idle_timeout=5,in_port=$IN_PORT,nw_dst=$NW_DST,actions=output:$OUT_PORT
	dpctl add-flow $DATAPATH idle_timeout=5,in_port=$OUT_PORT,nw_dst=$NW_SRC,actions=output:$IN_PORT
}

# add_flow dpctl
# add_flow ovs-ofctl dp0 5 tcp 1 65535 0 00:00:00:00:24:01 00:00:00:00:21:05 192.168.1.100 192.168.1.130 59522 22000 output:2

add_flow() {
	DPCTL=$1
	DATAPATH=$2

	IDLE_TIMEOUT=$3
	TRANSPORT=$4
	IN_PORT=$5
	DL_VLAN=$6
	DL_VLAN_PCP=$7
	DL_SRC=$8
	DL_DST=$9
	NW_SRC=$10
	NW_DST=$11
	TP_SRC=$12
	TP_DST=$13
	ACTIONS=$14

	echo "Add Flow: $DPCTL add-flow $DATAPATH idle_timeout=$IDLE_TIMEOUT,$TRANSPORT,in_port=$IN_PORT,dl_vlan=$DL_VLAN,dl_vlan_pcp=$DL_VLAN_PCP,dl_src=$DL_SRC,dl_dst=$DL_DST,nw_src=$NW_SRC,nw_dst=$NW_DST,tp_src=$TP_SRC,tp_dst=$TP_DST,actions=$ACTIONS"

	$DPCTL add-flow $DATAPATH idle_timeout=$IDLE_TIMEOUT,$TRANSPORT,in_port=$IN_PORT,dl_vlan=$DL_VLAN,dl_vlan_pcp=$DL_VLAN_PCP,dl_src=$DL_SRC,dl_dst=$DL_DST,nw_src=$NW_SRC,nw_dst=$NW_DST,tp_src=$TP_SRC,tp_dst=$TP_DST,actions=$ACTIONS
}

dump_flows() {
	DATAPATH=$1

	print_title_small "dump-flows"
	dpctl dump-flows $DATAPATH
	echo "dpctl dump-flows $DATAPATH"
}

dump_flows_nf() {
	HOST=$1
	DATAPATH=$2

	echo -e "\n\n $(__get_time) >>"
	ssh $HOST "dpctl dump-flows $DATAPATH"
}

dump_flows_procurve() {
	DATAPATH=$1

	echo -e "\n\n $(__get_time) >>"
	dpctl dump-flows $DATAPATH
}

monitor_nf() {
	HOST=$1
	DATAPATH=$2
	MAX_ITR=$3

    CNT=0	
	while [ $CNT -lt $MAX_ITR ]; do
	    dump_flows_nf $HOST $DATAPATH
		let CNT+=1
		sleep 5
	done
}

monitor_procurve() {
	DATAPATH=$1
	MAX_ITR=$2

    CNT=0	
	while [ $CNT -lt $MAX_ITR ]; do
	    dump_flows_procurve $DATAPATH
		let CNT+=1
		sleep 5
	done
}
