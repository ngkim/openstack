#!/bin/bash

source "$MNG_ROOT/include/print.sh"

check_sage_error_msg() {
	_MSG=$(awk 'BEGIN { err=0} /sageDisplayManager is already running/ { print $0; err=1; exit 0; } END { if (err == 0) print "OK"; }' $LOG_FSM)
	if [ "$_MSG" != "OK" ]; then
		print_err fsManager $_MSG
	fi

	_MSG=$(awk 'BEGIN { err=0} /read messages from fsManager/ { print $0; err=1; exit 0; } END { if (err == 0) print "OK"; }' $LOG_FSM)
	if [ "$_MSG" != "OK" ]; then
		print_err fsManager $_MSG
	fi
}

CREATED=0
check_slice_created() {
	_MODULE=$1
	_LOG=$2
	TIME_WAIT=$3

    for((i=0; i<$TIME_WAIT; i++)); do
	    _OK=$(awk 'BEGIN { count=0} /Reserved resources on/ { count=1 } END { print count }' $_LOG)
	    _ERR=$(awk 'BEGIN { err=0} /Fault/ { err=$0 } END { print err }' $_LOG)
    	if [ $_OK -eq 1 ]; then
    		LAUNCHED=1	
    		break
		elif [ "$_ERR" != "0" ]; then
			LAUNCHED=0
			break
    	fi
    	sleep 1
    done
    
    if [ $LAUNCHED -eq 1 ]; then
    	print_info $_MODULE "Slice created!!!"
		return 1
    else
    	print_err $_MODULE "Failed to create slice!! $_ERR"
		return 0
    fi
}

LAUNCHED=0
check_slice_approved() {
	_MODULE=$1
	_MSG=$2
	_LOG=$3
	TIME_WAIT=$4

    for((i=0; i<$TIME_WAIT; i++)); do
		$MNG_ROOT/bin/foam_slice_status.sh &>> $_LOG
	    _OK=$(awk 'BEGIN { count=0} /Approved/ { count=1 } END { print count }' $_LOG)
    	if [ $_OK -eq 1 ]; then
    		LAUNCHED=1	
    		break
    	fi
    	sleep 1
    done
    
    if [ $LAUNCHED -eq 1 ]; then
    	print_info $_MODULE "Slice approved!!!"
    else
    	print_err $_MODULE "Failed to approve slice!!"
    fi
}

DELETED=0	
check_slice_deleted() {
	_MODULE=$1
	SLIVER_URN=$2
	_LOG=$3
	TIME_WAIT=$4

    for((i=0; i<$TIME_WAIT; i++)); do
		COUNT=$($MNG_ROOT/bin/foam_slice_status.sh | grep $SLIVER_URN | grep -v grep | wc -l)
    	if [ $COUNT -eq 0 ]; then
    		DELETED=1
    		break
    	fi
    	sleep 1
    done
    
    if [ $DELETED -eq 1 ]; then
    	print_info $_MODULE "Sliver deleted!!!"
    else
    	print_err $_MODULE "Failed to delete sliver!!"
    fi
}

