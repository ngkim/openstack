#!/bin/bash

source "$MNG_ROOT/include/print.sh"

# modify it to run for seconds

_RUN_PPS_SWITCH=/tmp/.run_pps

log_pps() {
	IF=$1

	_RUN_PPS=`cat $_RUN_PPS_SWITCH`
	while [ $_RUN_PPS -eq 1 ]; do
    	RX=`cat /sys/class/net/$IF/statistics/rx_packets`
    	TX=`cat /sys/class/net/$IF/statistics/tx_packets`
   
		if [[ -n $_TX || -n $_RX ]]; then
			TXPPS=`expr $TX - $_TX`
	    	RXPPS=`expr $RX - $_RX`

			echo "$IF TX= $TXPPS pps RX= $RXPPS pps"
		fi 

		_TX=$TX
		_RX=$RX
    
		_RUN_PPS=`cat $_RUN_PPS_SWITCH`
    	sleep 1
	done
}

get_avg_pps() {
	IF=$1
	LOG_PPS=$2
	MIN=$3

	if [ -z $3 ]; then
		MIN=0
	fi

	awk -v min=$MIN '
	BEGIN {
		tx_count=0;
		rx_count=0;
		tx_sum=0; 
		rx_sum=0;
		max=0;
	} 
	/'"${IF}"'/ {
		if ($3 > min) {
			tx_sum+=$3; 
			tx_count++; 
		}
		if ($6 > min) {
			rx_sum+=$6;
			rx_count++;
		}
	} 
	END {
		tx_avg=0; rx_avg=0;
		if (tx_count > 0) tx_avg=tx_sum/tx_count; 
		if (rx_count > 0) rx_avg=rx_sum/rx_count; 
		printf "[PPS] TX average= %9.1f RX average= %9.1f\n", tx_avg, rx_avg
	}' $LOG_PPS
}

get_avg_multi_pps() {
	LOG_PPS=$1
	MIN=$2
    MAX_ITR=$3	

	if [ -z $2 ]; then
		MIN=0
	fi
	if [ -z $3 ]; then
		MAX_ITR=0
	fi

	awk -v min=$MIN -v max_itr=$MAX_ITR '
	BEGIN {
		pps_count=0;
		pps_sum=0; 
		max=0;
	} 
	{
		if( $2 > min ) { 
			pps_sum+=$2; 
			pps_count++; 
		}
	} 
	END {
		pps_avg=0;
		if (pps_count > max_itr) pps_count = max_itr;
		if (pps_count > 0) pps_avg=pps_sum/pps_count; 
		printf "[PPS] Average = %15.1f\n", pps_avg
		printf "      Total   = %15.1f Count= %d\n", pps_sum, pps_count
	}' $LOG_PPS
}

sum_multi_pps() {
	LOG_PPS=$1

	awk '
	BEGIN {
		pps_sum=0; 
	} 
	{
		pps_sum=0; 
		for ( i = 2; i <= NF; i++ ) {
			pps_sum+=$i; 
		}
		print $1, pps_sum
	}' $LOG_PPS
}

start_log_pps() {
	IF=$1
	LOG_PPS=$2

	echo "1" > $_RUN_PPS_SWITCH
	log_pps $IF &> $LOG_PPS &
}

stop_log_pps() {
	print_info "LOG_PPS" "Stop logging PPS..." 
	echo "0" > $_RUN_PPS_SWITCH
}
