#!/bin/bash


kill_pid() {
    PID_FILE=$1
    
    if [ -f $PID_FILE ]; then
    	IFSTAT_PID=`cat $PID_FILE`
    	echo "kill previous ifstat process= $IFSTAT_PID"
    	kill $IFSTAT_PID
            rm $PID_FILE
    fi
}

LIST_PID_FILE=`ls -a .ifstat*.pid`
for f in $LIST_PID_FILE; do
	kill_pid $f
done

