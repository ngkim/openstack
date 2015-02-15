list_processes() {
	NAMESPACE=$1
	HOST=$2
	HOST_KEY=$3
	PROC_NAME=$4
	
	#ip netns exec $NAMESPACE ssh -i $HOST_KEY $HOST "ps ax | grep $PROC_NAME | grep -v grep | grep -v avahi"
	ip netns exec $NAMESPACE ssh $HOST "ps ax | grep $PROC_NAME | grep -v grep | grep -v avahi"
}

count_processes() {
	NAMESPACE=$1
	HOST=$2
	HOST_KEY=$3
	PROC_NAME=$4

	#ip netns exec $NAMESPACE ssh -i $HOST_KEY $HOST "ps ax | grep $PROC_NAME | grep -v grep | grep -v avahi | wc -l"
	ip netns exec $NAMESPACE ssh $HOST "ps ax | grep $PROC_NAME | grep -v grep | grep -v avahi | wc -l"
}

kill_processes() {
	NAMESPACE=$1
	HOST=$2
	HOST_KEY=$3
	PROC_NAME=$4

	#PID_LIST=$(ip netns exec $NAMESPACE ssh -i $HOST_KEY $HOST "ps ax | grep $PROC_NAME | grep -v grep | grep -v avahi"  | awk '{print $1}')
	PID_LIST=$(ip netns exec $NAMESPACE ssh $HOST "ps ax | grep $PROC_NAME | grep -v grep | grep -v avahi"  | awk '{print $1}')

	for PROC_ID in $PID_LIST; do
		#ip netns exec $NAMESPACE ssh -i $HOST_KEY $HOST kill -9 $PROC_ID
		ip netns exec $NAMESPACE ssh $HOST kill -9 $PROC_ID
	done
}
