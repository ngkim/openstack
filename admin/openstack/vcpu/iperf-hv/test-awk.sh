#!/bin/bash

PORT=$1

tail -n 1 /tmp/iperf-server-$PORT.log | awk '{ 
	if ( $8 ~ /^G/ ) { 
		printf("G %.0f %s\n",$7*1000,$8);
	} else if ( $8 ~ /^M/ ) { 
		printf("M %.0f %s\n",$7, $8);
	}
}'

