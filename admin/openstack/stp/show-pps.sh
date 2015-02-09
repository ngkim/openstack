#!/bin/bash

# Interface configuration
# Need to update 
#tap765d9faf-ec tap204b217f-7f
# red tap02697538-05
#DEV_GREEN=qbr02697538-05
#DEV_GREEN_QVO=qbr765d9faf-ec
#DEV_ORANGE=qbr204b217f-7f
#DEV_ORANGE_QVO=tap204b217f-7f
#DEV_RED=eth0

DEV[0]=qbr02697538-05
DEV[1]=qbr765d9faf-ec
DEV[2]=qbr204b217f-7f
DEV[3]=int-br-hybrid

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

while true; do 
	for index in ${!DEV[*]}; do
		device=${DEV[$index]}
    	
    	R[$index]=$(get_rx_pkts $device)
    	T[$index]=$(get_tx_pkts $device)
	done

    sleep 1

	for index in ${!DEV[*]}; do
		device=${DEV[$index]}
    	
        R1[$index]=$(get_rx_pkts $device)
        T1[$index]=$(get_tx_pkts $device)
	done
    
    for index in ${!DEV[*]}; do
		device=${DEV[$index]}
    	
    	RX_PPS[$index]=`expr ${R1[$index]} - ${R[$index]}`
        TX_PPS[$index]=`expr ${T1[$index]} - ${T[$index]}`
        #echo ${R1[$index]} ${R[$index]}
    	#echo ${T1[$index]} ${T[$index]}
    	#echo ${TX_PPS[$index]} ${RX_PPS[$index]}
	done
    
    for index in ${!DEV[*]}; do
		device=${DEV[$index]}
    	                
        # Print pps result
        printf "%s: tx= %10s rx= %10s     " \
			"${green}${device}${normal}" ${TX_PPS[$index]} ${RX_PPS[$index]}
	done
	printf "\n"
done
