source "$MNG_ROOT/include/openstack/process.sh"

iperf_server_tcp() {
    NAMESPACE=$1
    SERVER_CTRL=$2
    SERVER_KEY=$3
    SERVER_LOG=$4

    ip netns exec $NAMESPACE ssh -i $SERVER_KEY $SERVER_CTRL "iperf -s -i 1"  &> $SERVER_LOG &
}

iperf_client_tcp() {
    NAMESPACE=$1
    CLIENT_CTRL=$2
    CLIENT_KEY=$3
    SERVER_DATA=$4
    CLIENT_LOG=$5
    TEST_DURATION=$6

    ip netns exec $NAMESPACE ssh -i $CLIENT_KEY $CLIENT_CTRL "iperf -c $SERVER_DATA -i 1 -t $TEST_DURATION" &> $CLIENT_LOG &
}

kill_iperf() {
    NAMESPACE=$1
    HOST=$2
    HOST_KEY=$3

    CNT=`count_processes $NAMESPACE $HOST $HOST_KEY iperf`
    if [ $CNT -gt 0 ]; then
		kill_processes $NAMESPACE $HOST $HOST_KEY iperf
    fi
}

analyze_iperf_log() {
	DIR=$1
	FILTER=$2

	files=`ls -l $DIR | grep server.$FILTER | awk '{print $9}'`
	for file in $files
	do
		report=`awk '/bits\/sec/ {line=$7 $8} END { print line}' $DIR/$file`
		printf "$file \t $report\n"
	done
}

get_iperf_log() {
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
			re=$(awk '/bits\/sec/ {line=$7 $8} END { print line}' $DIR/$file)
		else
			continue
		fi
	done

	echo $re
}
