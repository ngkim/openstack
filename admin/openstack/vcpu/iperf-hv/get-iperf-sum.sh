#!/bin/bash


get_throughput() {
	PORT=$1

	VAL=`tail -n 1 /tmp/iperf-server-$PORT.log | awk '{ 
    THPUT=sprintf("%.2f",$7)
	if ( $8 ~ /^G/ ) { 
		printf("%.0f %s\n",THPUT*1000,$8);
	} else if ( $8 ~ /^M/ ) { 
		printf("%.0f %s\n",THPUT, $8);
	}
}'`

	echo $VAL
}

SUM=0
for i in `seq 5001 5016`; do
	THPUT=`get_throughput ${i} | awk '{print $1}'`
	echo "${i}= $THPUT"
	SUM=`expr $SUM + $THPUT`
done

echo "*** SUM= $SUM"
