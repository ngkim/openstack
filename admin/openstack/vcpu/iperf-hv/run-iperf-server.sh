#!/bin/bash

run_iperf_server() {
	PORT=$1
	CORE=$2

	if [ -z $1 ]; then
		PORT=5001
	fi

	if [ -z $2 ]; then
		iperf -s -p $PORT -i 1 
	else
		echo "taskset $CORE iperf -s -p $PORT -i 1"
		taskset $CORE iperf -s -p $PORT -i 1
	fi
}

killall iperf
sleep 1

run_server_bind() {
	run_iperf_server 5001 00000001 &> /tmp/iperf-server-5001.log &
	run_iperf_server 5002 00000002 &> /tmp/iperf-server-5002.log &
	run_iperf_server 5003 00000004 &> /tmp/iperf-server-5003.log &
	run_iperf_server 5004 00000008 &> /tmp/iperf-server-5004.log &

	run_iperf_server 5005 00000010 &> /tmp/iperf-server-5005.log &
	run_iperf_server 5006 00000020 &> /tmp/iperf-server-5006.log &
	run_iperf_server 5007 00000040 &> /tmp/iperf-server-5007.log &
	run_iperf_server 5008 00000080 &> /tmp/iperf-server-5008.log &

	run_iperf_server 5009 00010000 &> /tmp/iperf-server-5009.log &
	run_iperf_server 5010 00020000 &> /tmp/iperf-server-5010.log &
	run_iperf_server 5011 00040000 &> /tmp/iperf-server-5011.log &
	run_iperf_server 5012 00080000 &> /tmp/iperf-server-5012.log &

	run_iperf_server 5013 00100000 &> /tmp/iperf-server-5013.log &
	run_iperf_server 5014 00200000 &> /tmp/iperf-server-5014.log &
	run_iperf_server 5015 00400000 &> /tmp/iperf-server-5015.log &
	run_iperf_server 5016 00800000 &> /tmp/iperf-server-5016.log &
}

run_server() {
	for i in `seq 5001 5004`; do
		run_iperf_server $i &> /tmp/iperf-server-${i}.log &
	done
}

run_server_bind
