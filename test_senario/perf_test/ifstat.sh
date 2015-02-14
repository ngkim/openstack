#!/bin/bash

if [ -z $1 ]; then
	echo "$0 [perf-name]"
	exit
fi

PERF_NAME=$1

# GREEN, ORANGE, RED
itf_vm_20="tap195bd433-d8,tap5252688c-94,tap7ba2a378-1f"






LOG_DIR=/tmp/ifstat/

DIR_LOG="${LOG_DIR}${PERF_NAME}"
LOG_IFSTAT="${DIR_LOG}/ifstat.log"
PID_FILE=".ifstat.pid"

if [ -f $PID_FILE ]; then
	IFSTAT_PID=`cat $PID_FILE`
	echo "kill previous ifstat process= $IFSTAT_PID"
	kill $IFSTAT_PID
        rm $PID_FILE
fi

if [ -d $DIR_LOG ]; then
	echo "duplicated log dir= $DIR_LOG"
	echo "use different experiment name ($PERF_NAME)"
	exit
else
	echo "create log dir= $DIR_LOG"
	mkdir -p $DIR_LOG
fi

ifstat -b -i p1p1,phy-br-hybrid,int-br-hybrid,$itf_vm_20 &> ${LOG_IFSTAT} &
echo $! > $PID_FILE
tailf ${LOG_IFSTAT}


