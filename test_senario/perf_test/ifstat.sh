#!/bin/bash

if [ -z $1 ]; then
	echo "$0 [perf-name]"
	exit
fi

PERF_NAME=$1

# GREEN, ORANGE, RED
ITF_VM[20]="tap195bd433-d8,tap5252688c-94,tap7ba2a378-1f"
#ITF_VM[22]="tapb7e522ab-a7,tap10ac0abf-e9,tapd61f1ef6-2e"
#ITF_VM[24]="tapd7147860-0e,tapcc9bb69a-d7,tap5eba3a43-7d"
#ITF_VM[26]="tapd8dbf89d-13,tapd331b27e-e1,tap754279c6-d2"
#ITF_VM[28]="tap2f9264a3-0d,tap87e2dee2-6b,tapfe4a3996-63"
#ITF_VM[30]="tap3676c75e-5a,tap1c3b41a6-7a,tapc411e7d7-f5"
#ITF_VM[32]="tap966d9915-cf,tap146affad-d6,tape3ae2967-67"
#ITF_VM[34]="tap1251d0e8-bf,tapc783e932-65,tapbf9d8692-08"
#ITF_VM[36]="tap57bc4118-87,tapc720c799-bf,tapbd51344c-63"
#ITF_VM[38]="tapf8b576c8-82,tapeabc2185-47,tap7a867cf7-ce"

LOG_DIR=/tmp/ifstat/

DIR_LOG="${LOG_DIR}${PERF_NAME}"

if [ -d $DIR_LOG ]; then
	echo "duplicated log dir= $DIR_LOG"
	echo "use different experiment name ($PERF_NAME)"
	exit
else
	echo "create log dir= $DIR_LOG"
	mkdir -p $DIR_LOG
fi
	
log_ifstat() {
	declare -a VM_ITF_LIST=("${!1}")

	for vm_idx in ${!VM_ITF_LIST[@]}; do
		LOG_IFSTAT="${DIR_LOG}/ifstat-vm-$vm_idx.log"
		PID_FILE=".ifstat-$vm_idx.pid"

		if [ -f $PID_FILE ]; then
			IFSTAT_PID=`cat $PID_FILE`
			echo "kill previous ifstat process= $IFSTAT_PID"
			kill $IFSTAT_PID
	       		rm $PID_FILE
		fi
	
		vm_itf=${VM_ITF_LIST[$vm_idx]}
		ifstat -b -i p1p1,phy-br-hybrid,int-br-hybrid,$vm_itf &> ${LOG_IFSTAT} &

		echo $! > $PID_FILE
	done

	tailf ${LOG_IFSTAT}
}

log_ifstat ITF_VM[@]



