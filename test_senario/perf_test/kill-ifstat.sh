#!/bin/bash

PID_FILE=".ifstat.pid"

if [ -f $PID_FILE ]; then
	IFSTAT_PID=`cat $PID_FILE`
	echo "kill previous ifstat process= $IFSTAT_PID"
	kill $IFSTAT_PID
        rm $PID_FILE
fi

