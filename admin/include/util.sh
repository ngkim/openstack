clear_arp() {
	HOST=$1
	IP=$2

	ssh $HOST "arp -d $IP"
}

clear_host_arp() {
    for (( i=1; i <= ${#_hosts[@]}; i++ )); do
        _END_HOST=$(echo ${_hosts[$i]} | awk '{print $1}')
        for (( j=1; j <= ${#_hosts[@]}; j++ )); do
			if [ $i -eq $j ]; then
				continue;
			fi
            _END_IP=$(echo ${_hosts[$j]} | awk '{print $2}')
            clear_arp $_END_HOST $_END_IP &> /dev/null &
        done
    done
}

clear_arp_sage() {
	for (( i=1; i <= ${#sage_hosts[@]}; i++ )); do	
		_END_HOST=$(echo ${sage_hosts[$i]} | awk '{print $1}')
	    for (( j=1; j <= ${#sage_hosts[@]}; j++ )); do	
			if [ $i -eq $j ]; then
                continue;
            fi 
		    _END_IP=$(echo ${sage_hosts[$j]} | awk '{print $2}')
 		    clear_arp $_END_HOST $_END_IP &> /dev/null &
		done
	done
}

list_arp() {
	HOST=$*

	ssh $HOST "arp -n"
}

__get_time() {
	_TIME=$(date | awk '{print $4}')
	echo $_TIME
}

__get_date() {
  	_DATE=`date +%Y%m%d%H%M`
	echo $_DATE
}

generate_mac_address() {
    #set integer ceiling
    RANGE=255
    
    #generate random numbers
    number=$RANDOM
    numbera=$RANDOM
    numberb=$RANDOM
    
    #ensure they are less than ceiling
    let "number %= $RANGE"
    let "numbera %= $RANGE"
    let "numberb %= $RANGE"
    
    #set mac stem
    octets='00:60:2F'
    
    #use a command line tool to change int to hex(bc is pretty standard)
    #they're not really octets.  just sections.
    octeta=`echo "obase=16;$number" | bc`
    octetb=`echo "obase=16;$numbera" | bc`
    octetc=`echo "obase=16;$numberb" | bc`
    
    #concatenate values and add dashes
    macadd="${octets}:${octeta}:${octetb}:${octetc}"
    
    echo $macadd
}
