has_connection() {
	SRC=$1
	DST=$2
	COUNT=$3

	if [ -z "$4" ]; then 
		SSH_PORT=22
    	else
		SSH_PORT=$4
    	fi


	re=""
	cnt=$(ssh -p $SSH_PORT $(get_USER_ID $SRC)@$(get_CTRLIP $SRC) ping -c $COUNT $DST | grep 'received' | awk -F',' '{ print $2 }' | awk '{ print $1 }')
  	if [ $cnt -eq 0 ]; then
		re="Error!"
	else
		re="OK."
	fi
	echo $re
}

is_connected() {
	SRC=$1
	DST=$2
	COUNT=$3

	if [ -z "$4" ]; then 
		SSH_PORT=22
    	else
		SSH_PORT=$4
    	fi

	re=0
	cnt=$(ssh -p $SSH_PORT $(get_USER_ID $SRC)@$(get_CTRLIP $SRC) ping -c $COUNT $DST | grep 'received' | awk -F',' '{ print $2 }' | awk '{ print $1 }')
  	if [ $cnt -eq 0 ]; then
		re=0
	else
		re=1
	fi
	echo $re
}

ping_simple() {
    	CTRL_ADDR=$1
    	TARGET=$2
	
	if [ -z "$3" ]; then 
		SSH_PORT=22
    	else
		SSH_PORT=$3
    	fi

    	ssh -p $SSH_PORT $CTRL_ADDR "ping -c 3 $TARGET"
}

ping_host() {
	COUNT=3
	myHost=$1

	re=''
	count=$(ping -c $COUNT $myHost | grep 'received' | awk -F',' '{ print $2 }' | awk '{ print $1 }')
	if [ $count -eq 0 ]; then
		re="OFF"
 	else
 		re="ON"
 	fi   

	echo $re
}

ping_log() {
    	CTRL_ADDR=$1
    	TARGET=$2
    	LOG=$3  

	if [ -z "$4" ]; then 
		SSH_PORT=22
    	else
		SSH_PORT=$4
    	fi

    	ssh -p $SSH_PORT $CTRL_ADDR "ping $TARGET -c 3" &> $LOG &
}

kill_ping() {
    	HOST=$1

	if [ -z "$2" ]; then 
		SSH_PORT=22
    	else
		SSH_PORT=$2
    	fi

    	ssh -p $SSH_PORT $HOST "killall ping"
}

#ping_host cap01.postech
