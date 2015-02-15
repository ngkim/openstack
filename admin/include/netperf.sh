source "$MNG_ROOT/include/process.sh"

netperf_client_tcp() {
    CLIENT_CTRL=$1
    SERVER_DATA=$2
    CLIENT_LOG=$3
    TEST_DURATION=$4

    if [ -z "$5" ]; then 
	SSH_PORT=22
    else
	SSH_PORT=$5
    fi

    ssh -p $SSH_PORT $CLIENT_CTRL "netperf -t TCP_STREAM -H $SERVER_DATA C -c -f M -l $TEST_DURATION -D" &> $CLIENT_LOG &
}

kill_netperf() {
    HOST=$1

    if [ -z "$2" ]; then 
		SSH_PORT=22
    else
		SSH_PORT=$2
    fi
	
	PS_NAME=netperf

    CNT=$(count_processes $HOST $PS_NAME $SSH_PORT)
    if [ $CNT -gt 0 ]; then
		kill_processes $HOST $PS_NAME $SSH_PORT	
    fi
}

analyze_netperf_log() {
	DIR=$1
	FILTER=$2

	files=$( ls -l $DIR | grep server.$FILTER | awk '{print $8}')
	for file in $files
	do
		report=$(awk '/bits\/sec/ {line=$7 $8} END { print line}' $DIR/$file)
		printf "$file \t $report Mbps\n"
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
			re=$(awk '/bits\/sec/ {line=$7 $8} END { print line}' $DIR/$file)
		else
			continue
		fi
	done

	echo $re
}


