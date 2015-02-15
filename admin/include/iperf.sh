source "$MNG_ROOT/include/process.sh"

iperf_server_udp() {
    SERVER_CTRL=$1
    SERVER_LOG=$2

    if [ -z "$3" ]; then 
	SSH_PORT=22
    else
	SSH_PORT=$3
    fi

    ssh -p $SSH_PORT $SERVER_CTRL "iperf -s -u -i 1"  &> $SERVER_LOG &
}

iperf_client_udp() {
    CLIENT_CTRL=$1
    SERVER_DATA=$2
    CLIENT_LOG=$5
    TEST_BW=$3
    TEST_DURATION=$4

    if [ -z "$6" ]; then 
	SSH_PORT=22
    else
	SSH_PORT=$6
    fi


    ssh -p $SSH_PORT $CLIENT_CTRL "iperf -c $SERVER_DATA -u -b $TEST_BW -i 1 -t $TEST_DURATION" &> $CLIENT_LOG &
}

iperf_server_tcp() {
    SERVER_CTRL=$1
    SERVER_LOG=$2

    if [ -z "$3" ]; then 
	SSH_PORT=22
    else
	SSH_PORT=$3
    fi

    ssh -p $SSH_PORT $SERVER_CTRL "iperf -s -i 1"  &> $SERVER_LOG &
}

iperf_client_tcp() {
    CLIENT_CTRL=$1
    SERVER_DATA=$2
    CLIENT_LOG=$3
    TEST_DURATION=$4
    MSS_SIZE=$5

    if [ -z "$5" ]; then 
    	ssh -p $SSH_PORT $CLIENT_CTRL "iperf -c $SERVER_DATA -i 1 -t $TEST_DURATION" &> $CLIENT_LOG &
    else
    	ssh -p $SSH_PORT $CLIENT_CTRL "iperf -c $SERVER_DATA -i 1 -M $MSS_SIZE -t $TEST_DURATION" &> $CLIENT_LOG &
    fi
}

kill_iperf() {
    HOST=$1

    if [ -z "$2" ]; then 
	SSH_PORT=22
    else
	SSH_PORT=$2
    fi

    CNT=$(count_processes $HOST iperf $SSH_PORT)
    if [ $CNT -gt 0 ]; then
	kill_processes $HOST iperf $SSH_PORT	
    fi
}

analyze_iperf_log() {
	DIR=$1
	FILTER=$2

	files=$( ls -l $DIR | grep server.$FILTER | awk '{print $8}')
	for file in $files
	do
		report=$(awk '/bits\/sec/ {line=$7 $8} END { print line}' $DIR/$file)
		printf "$file \t $report Mbps\n"
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


