check_halt() {
    if [ -z $HALT ]; then
	  HALT=0
	elif [ $HALT -eq 1 ]; then
	  exit
    fi
}

###### Functions
check_switch() {
	NAME=$1
	DPID=$2
	SWITCHES=("${!3}")
	FOUND=0

    for SW in $SWITCHES; do
    	if [ $SW == $DPID ]; then
    	  echo -e "\t- $NAME"
		  FOUND=1
    	fi
    done

	if [ $FOUND -eq 0 ]; then
	  	print_err flowvisor "SWITCH '$NAME' is not connected!!!"
		HALT=1
    fi
}

check_slice() {
	_NAME=$1
	_SLICES=("${!2}")
	_FV_SERVER=$3
	_NOX=$4
	_SLICE=$_NAME
	_SLICE_PASSWD=$5

	FOUND=0

    for SL in $SLICES; do
    	if [ "$SL" == "$_NAME" ]; then
			echo -e "\t- $SL"
			FOUND=1
		fi
	done

	if [ $FOUND -eq 0 ]; then
	  	print_info flowvisor "SLICE '$_NAME' does not exist! Create slice '$_NAME'!"
		fv_add_slice $_FV_SERVER $_NOX $_SLICE $_SLICE_PASSWD &> $__LOG_FV
    fi
}

clear_existing_flowspaces() {
	__FV_SERVER=$1
	_SLICE=$2

    fv_get_flowspace $__FV_SERVER &> $__LOG_FV_CNT
    __COUNT_FS=$(cat $__LOG_FV_CNT | grep rule | grep $_SLICE= | grep FlowEntry | wc -l)
    
    while [ $__COUNT_FS -gt 0 ]; do
        print_info flowvisor "Remove existing FlowSpaces in $SLICE slice."
        fv_remove_flowspace $__FV_SERVER $SLICE
    
    	rm -rf $__LOG_FV_CNT
        fv_get_flowspace $__FV_SERVER &> $__LOG_FV_CNT
        __COUNT_FS=$(cat $__LOG_FV_CNT | grep rule | grep $SLICE= | grep FlowEntry | wc -l)
    done
}

nox_with_json() {
	NOX_SERVER=$1
	LAVI_PORT=$2
	TRNS_PORT=$3

    kill_processes_nox_with_json $NOX_SERVER $LAVI_PORT
    check_nox_with_json $NOX_SERVER $LAVI_PORT &> $__LOG_NOX_PS
    COUNT=$(cat $__LOG_NOX_PS | grep nox_core | wc -l)
    if [ $COUNT -eq 0 ]; then
        print_info nox "Start NOX at $NOX_SERVER..."
		echo $__LOG_NOX
        run_nox_with_json $NOX_SERVER $TRNS_PORT $NOX_APP &> $__LOG_NOX &
		sleep 3
	fi
    sleep 3
    check_nox_with_json $NOX_SERVER $LAVI_PORT &> $__LOG_NOX_PS
    COUNT=$(cat $__LOG_NOX_PS | grep nox_core | wc -l)
    check_nox_running $COUNT

    check_halt
}

auto_translate() {
	NOX_SERVER=$1
	TRNS_PORT=$2

    check_auto_translate $NOX_SERVER $TRNS_PORT &> $__LOG_NOX_PS
    COUNT=$(cat $__LOG_NOX_PS | grep AutoTranslate | grep $TRNS_PORT | wc -l)
    if [ $COUNT -eq 1 ]; then
    	print_info nox "AutoTranslate on $TRNS_PORT is running. Kill and restart"
		kill_processes_autotranslate $NOX_SERVER $TRNS_PORT
    	run_auto_translate $NOX_SERVER $TRNS_PORT &> $__LOG_TRNS.$TRNS_PORT &
    elif [ $COUNT -eq 0 ]; then
    	print_info nox "Start AutoTranslate on $TRNS_PORT..."
    	run_auto_translate $NOX_SERVER $TRNS_PORT &> $__LOG_TRNS.$TRNS_PORT &
    else
    	print_err nox "Multiple instances of AutoTranslate on $TRNS_PORT is running."
    	HALT=1
    fi
    check_halt
}

kill_nox_with_json() {
	NOX_SERVER=$1
	LAVI_PORT=$2

    check_nox_with_json $NOX_SERVER $LAVI_PORT &> $__LOG_NOX_PS
    COUNT=$(cat $__LOG_NOX_PS | grep nox_core | wc -l)
    if [ $COUNT -gt 0 ]; then
    	print_info nox "Clear running nox instances."
    	kill_processes_nox_with_json $NOX_SERVER $LAVI_PORT
    fi
}
