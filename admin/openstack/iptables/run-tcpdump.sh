#!/bin/bash

source "$MNG_ROOT/include/print.sh"
source "./dev_id.conf"

run_tcpdump() {
	DEV=$1
	tcpdump -i $DEV -ne -l arp or icmp &> dump/$DEV.dump &

	echo $!	
}

PID_TAP_GREEN=$(run_tcpdump "tap$DEV_ID_GREEN")
PID_QVO_GREEN=$(run_tcpdump "qvo$DEV_ID_GREEN")
PID_TAP_ORANGE=$(run_tcpdump "tap$DEV_ID_ORANGE")
PID_QVO_ORANGE=$(run_tcpdump "qvo$DEV_ID_ORANGE")

sleep 5

kill_process() {
	PID=$1
	echo "Kill $PID"
	kill $PID	
}

kill_process $PID_TAP_GREEN
kill_process $PID_QVO_GREEN
kill_process $PID_TAP_ORANGE
kill_process $PID_QVO_ORANGE

MODE="TCPDUMP"

read_dump() {
	DEV=$1
	print_info $MODE "$DEV.dump"
	cat dump/$DEV.dump
}

read_dump "tap$DEV_ID_GREEN"
read_dump "qvo$DEV_ID_GREEN"
read_dump "tap$DEV_ID_ORANGE"
read_dump "qvo$DEV_ID_ORANGE"
