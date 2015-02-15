source "$MNG_ROOT/include/openstack/process.sh"

netperf_client_tcp() {
    NAMESPACE=$1
    CLIENT_CTRL=$2
    CLIENT_KEY=$3
    SERVER_DATA=$4
    CLIENT_LOG=$5
    TEST_DURATION=$6
	MSG_SIZE=$7

	if [ -z $MSG_SIZE ]; then
		MSG_SIZE=16384
	fi

    ip netns exec $NAMESPACE ssh -i $CLIENT_KEY $CLIENT_CTRL "netperf -t TCP_STREAM -H $SERVER_DATA C -c -f g -l $TEST_DURATION -D -- -m $MSG_SIZE" &> $CLIENT_LOG &
}

kill_netperf() {
    NAMESPACE=$1
    HOST=$2
    HOST_KEY=$3

	PS_NAME=netperf

    CNT=`count_processes $NAMESPACE $HOST $HOST_KEY $PS_NAME`
    if [ $CNT -gt 0 ]; then
		kill_processes $NAMESPACE $HOST $HOST_KEY $PS_NAME
    fi
}

analyze_netperf_log() {
	DIR=$1
	FILTER=$2

	files=$( ls $DIR | grep client.$FILTER | awk '{print $1}')
	for file in $files
	do
		#report=$(awk '/bits\/sec/ {line=$7 $8} END { print line}' $DIR/$file)
		report_bw=$(tail -n 1 $DIR/$file |  awk '{line=$5} END { print line}')
		report_cpu=$(tail -n 1 $DIR/$file |  awk '{line=$6} END { print line}')
		printf "$file \t $report_bw Gbps -- CPU usage= $report_cpu percent\n"
	done
}

get_netperf_log() {
	DIR=$1
	FILTER=$2
	SRC=$3
	DST=$4

	re=''
#	files=$( ls -l $DIR | grep server.$FILTER | grep $SRC | grep $DST | awk '{print $8}')
	files=$( ls $DIR | grep server.$FILTER | grep $SRC | grep $DST)
	for file in $files
	do
		client=$(echo $file | awk -F $FILTER] '{print $2}' | awk -F --- '{print $1}')
		if [ $client == $SRC ]; then
			re=$(tail -n 1 $DIR/$file |  awk '{line=$5} END { print line}')
		else
			continue
		fi
	done

	echo $re
}
