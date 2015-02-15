#!/bin/bash

source "$MNG_ROOT/include/print.sh"

# modify it to run for seconds

_RUN_STAT_FILE=/tmp/.run_mpstat

get_interrupt() {
    ITR_NO=$1 
    CPU_NO=$2

awk '
{
    if($1 ~ /'${ITR_NO}':/){ 
        printf ("%6s %6s %6s %6s\n", $1, $'${CPU_NO}', $3, $4);
    }
}' /proc/interrupts 
}

log_stat() {
	IF=$1

	_RUN_STAT=`cat $_RUN_STAT_FILE`
	while [ $_RUN_STAT -eq 1 ]; do
    	ITR_1=`get_interrupt 98 2`
#    	ITR_2=`awk '/p1p1-TxRx-0/ {print $3}' /proc/interrupts`
#    	ITR_3=`awk '/p1p1-TxRx-0/ {print $4}' /proc/interrupts`
#    	ITR_4=`awk '/p1p1-TxRx-0/ {print $5}' /proc/interrupts`

		echo "ITR_1= $ITR_1"
		ITR_1_S=`expr $ITR_1 - $ITR_1_`
#		ITR_2_S=`expr $ITR_2 - $_ITR_2`
#		ITR_3_S=`expr $ITR_3 - $_ITR_3`
#		ITR_4_S=`expr $ITR_4 - $_ITR_4`

		echo "p1p1-TxRx-0 CPU1= $ITR_1_S CPU2= $ITR_2_S CPU3= $ITR_3_S CPU4= $ITR_4_S"

		ITR_1_=$ITR_1
#		_ITR_2=$ITR_2 
#		_ITR_3=$ITR_3
#		_ITR_4=$ITR_4
		echo "ITR_1_= $ITR_1_"
    
		_RUN_STAT=`cat $_RUN_STAT_FILE`
    	sleep 1
	done
}

start_log_stat() {
	IF=$1
	LOG_STAT=$2

	echo "1" > $_RUN_STAT_FILE
	log_stat $IF &> $LOG_STAT &
}

stop_log_stat() {
	print_info "LOG_STAT" "Stop logging STAT..." 
	echo "0" > $_RUN_STAT_FILE
}
