check_nox_process() {
	print_title_small " NOX processes..."
	list_processes $NOX_SERVER nox
}

check_fv_process() {
        print_title_small " FlowVisor processes..."
	list_processes $FV_SERVER flowvisor
}

check_ovs_process() {
	print_title_small " ovs processes..."
	for n in $ctrl_nodes; do
	    echo "- $n"
		list_processes $n ovs
	    echo ""
	done 
}

check_cap_process() {
	print_title_small " capsulator processes... "
	for n in $ctrl_nodes; do
	    echo "- $n"
		list_processes $n capsulator
	    echo ""
	done 
	print_space
}

check_fv_slice_flowspace() {
	print_title_small " Slices and FlowSpaces at $FV_SERVER"
	ssh $FV_SERVER "fvctl --passwd-file=/home/xgist/passwd listSlices"
	ssh $FV_SERVER "fvctl --passwd-file=/home/xgist/passwd listFlowSpace"
}

list_processes() {
	HOST=$1
	PROC_NAME=$2
	
	if [ -z "$3" ]; then 
	    SSH_PORT=22
    	else
	    SSH_PORT=$3
        fi

	ssh -p $SSH_PORT $HOST "ps ax | grep $PROC_NAME | grep -v grep | grep -v avahi"
}

count_processes() {
	HOST=$1
	PROC_NAME=$2

	if [ -z "$3" ]; then 
	    SSH_PORT=22
    	else
	    SSH_PORT=$3
        fi

#	ssh $HOST "ps ax | grep $PROC_NAME | grep python | grep -v grep"
	ssh -p $SSH_PORT $HOST "ps ax | grep $PROC_NAME | grep -v grep | grep -v avahi | wc -l"
}

kill_processes() {
	HOST=$1
	PROC_NAME=$2

	if [ -z "$3" ]; then 
	    SSH_PORT=22
    	else
	    SSH_PORT=$3
        fi

	#list_processes $HOST $PROC_NAME	$SSH_PORT
	PID_LIST=$(ssh -p $SSH_PORT $HOST "ps ax | grep $PROC_NAME | grep -v grep | grep -v avahi"  | awk '{print $1}')

	for PROC_ID in $PID_LIST; do
		#echo "     KILL $PROC_NAME ($PROC_ID) at $HOST"
		ssh -p $SSH_PORT $HOST kill -9 $PROC_ID
	done
}

kill_local_processes() {
    PROC_NAME=$1

    #list_processes $HOST $PROC_NAME    $SSH_PORT
    PID_LIST=$(ps ax | grep $PROC_NAME | grep -v grep | grep -v avahi | awk '{print $1}')

    for PROC_ID in $PID_LIST; do
        #echo "     KILL $PROC_NAME ($PROC_ID) at $HOST"
        kill $PROC_ID
    done
}

list_processes_nox_with_json() {
	HOST=$1
	JSON_PORT=$2
	
	if [ -z "$3" ]; then 
	    SSH_PORT=22
    	else
	    SSH_PORT=$3
        fi

	ssh -p $SSH_PORT $HOST "ps ax | grep nox_core | grep $JSON_PORT | grep -v grep | grep -v avahi"
}

kill_processes_nox_with_json() {
	HOST=$1
	JSON_PORT=$2
	PROC_NAME="nox_core"

    if [ -z "$3" ]; then 
	    SSH_PORT=22
    else
	    SSH_PORT=$3
    fi

	#list_processes $HOST $PROC_NAME	$SSH_PORT
	PID_LIST=$(ssh -p $SSH_PORT $HOST "ps ax | grep $PROC_NAME | grep $JSON_PORT | grep -v grep | grep -v avahi"  | awk '{print $1}')

	for PROC_ID in $PID_LIST; do
		echo "     KILL $PROC_NAME ($PROC_ID) at $HOST"
		ssh -p $SSH_PORT $HOST "kill -9 $PROC_ID"
	done
}

kill_processes_autotranslate() {
	HOST=$1
	TRNS_PORT=$2

    if [ -z "$3" ]; then 
	    SSH_PORT=22
    else
	    SSH_PORT=$3
    fi

	#list_processes $HOST $PROC_NAME	$SSH_PORT
	PROC_NAME="AutoTranslate"
	PID_LIST=$(ssh -p $SSH_PORT $HOST "ps ax | grep $PROC_NAME |  grep $TRNS_PORT | grep -v grep"  | awk '{print $1}')

	for PROC_ID in $PID_LIST; do
		echo "     KILL $PROC_NAME ($PROC_ID) at $HOST"
		ssh -p $SSH_PORT $HOST "kill -9 $PROC_ID"
	done

	PROC_NAME="Translate"
	PID_LIST=$(ssh -p $SSH_PORT $HOST "ps ax | grep $PROC_NAME | grep python |  grep $TRNS_PORT | grep -v grep"  | awk '{print $1}')

	for PROC_ID in $PID_LIST; do
		echo "     KILL $PROC_NAME ($PROC_ID) at $HOST"
		ssh -p $SSH_PORT $HOST "kill -9 $PROC_ID"
	done
}
