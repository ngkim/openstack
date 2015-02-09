#!/bin/bash

run_iperf_client() {
	DEST=$1
	PORT=$2
	CORE=$3

	if [ -z $2 ]; then
		PORT=5001
	fi

	if [ -z $3 ]; then
		iperf -c $DEST -p $PORT -i 1 
	else
		taskset $CORE iperf -c $DEST -p $PORT -i 1
	fi
}

killall iperf
sleep 1

run_client_bind() {
	run_iperf_client 10.20.20.52 5001 00000001 &> /tmp/iperf-client-5001.log &
	run_iperf_client 10.20.20.52 5002 00000002 &> /tmp/iperf-client-5002.log &
	run_iperf_client 10.20.20.52 5003 00000004 &> /tmp/iperf-client-5003.log &
	run_iperf_client 10.20.20.52 5004 00000008 &> /tmp/iperf-client-5004.log &
}

run_client() {
	run_iperf_client 10.20.20.52 5001 &> /tmp/iperf-client-5001.log &
	run_iperf_client 10.20.20.52 5002 &> /tmp/iperf-client-5002.log &
	run_iperf_client 10.20.20.52 5003 &> /tmp/iperf-client-5003.log &
	run_iperf_client 10.20.20.52 5004 &> /tmp/iperf-client-5004.log &
}

echo "Start iperf client..."
run_client
echo "Done!!!"
