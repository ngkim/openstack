#!/bin/bash

# Interface configuration
# Need to update 
DEV_GREEN=br0
DEV_ORANGE=br1
DEV_RED=eth0

# Color codes 
green=$(tput setaf 2)
orange=$(tput setaf 3)
red=$(tput setaf 1)
normal=$(tput sgr0) 

get_rx_pkts() {
	DEV=$1

        cat /sys/class/net/$DEV/statistics/rx_packets
}

get_tx_pkts() {
	DEV=$1

        cat /sys/class/net/$DEV/statistics/tx_packets
}

while true
do
        R0=$(get_rx_pkts $DEV_GREEN)
        T0=$(get_tx_pkts $DEV_GREEN)

        R1=$(get_rx_pkts $DEV_ORANGE)
        T1=$(get_tx_pkts $DEV_ORANGE)

        R2=$(get_rx_pkts $DEV_RED)
        T2=$(get_tx_pkts $DEV_RED)

        sleep 1

        R0_1=$(get_rx_pkts $DEV_GREEN)
        T0_1=$(get_tx_pkts $DEV_GREEN)

        R1_1=$(get_rx_pkts $DEV_ORANGE)
        T1_1=$(get_tx_pkts $DEV_ORANGE)

        R2_1=$(get_rx_pkts $DEV_RED)
        T2_1=$(get_tx_pkts $DEV_RED)

        # Compute difference
        TX0_PPS=`expr $T0_1 - $T0`
        RX0_PPS=`expr $R0_1 - $R0`

        TX1_PPS=`expr $T1_1 - $T1`
        RX1_PPS=`expr $R1_1 - $R1`

        TX2_PPS=`expr $T2_1 - $T2`
        RX2_PPS=`expr $R2_1 - $R2`

        # Print pps result
        printf "%s: tx= %10s rx= %10s    %s: tx= %10s rx= %10s    %s: tx= %10s rx= %10s\n" \
		"${green}${DEV_GREEN}${normal}" $TX0_PPS $RX0_PPS \
		"${orange}${DEV_ORANGE}${normal}" $TX1_PPS $RX1_PPS \
		"${red}${DEV_RED}${normal}" $TX2_PPS $RX2_PPS
done
