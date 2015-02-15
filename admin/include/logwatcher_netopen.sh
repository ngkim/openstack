#!/bin/bash

source "$MNG_ROOT/include/print.sh"

check_single_switch() {
	S=$1
	_MODULE=$2
	_LOG=$3

    awk -v s=$S 'BEGIN { count=0} /joins$/ { if ($2 == s) { count+=1; }} /leaves$/ { if ($2 == s) { count-=1; }} END { print count; print NR > ".line.switch" }' $_LOG

}

ALL_CONNECTED=0
check_switches_connected() {
	_MODULE=$1
	_LOG=$2
	COUNT=$3
	TIME_WAIT=$4

    print_info $_MODULE "Start checking switches connected!!!"

    for((i=0; i<$TIME_WAIT; i++)); do
		_COUNT=0
		for (( j=1; j <= ${#switches[@]}; j++)); do
			switch_id=$(echo ${switches[$j]} | awk '{print $2}' | sed 's/^0*//')
			eval switch_id=$switch_id
			switch_id=$(echo $switch_id | sed 's/^0*//')
			_CNT=$(check_single_switch $switch_id $_MODULE $_LOG)
			_COUNT=$(echo "$_COUNT+$_CNT" | bc)
		done

		if [ $_COUNT -eq ${#switches[@]} ]; then
    		ALL_CONNECTED=1	
			break
		else
	    	_ERR=$(awk 'BEGIN { err=0} /Fault/ { err=$0 } END { print err }' $_LOG)
			if [ "$_ERR" != "0" ]; then
    			ALL_CONNECTED=0
				break;
			fi
		fi

    	sleep 1
    done
    
    if [ $ALL_CONNECTED -eq 1 ]; then
    	print_info $_MODULE "All switches are connected!!!"
		return 1
    else
    	print_err $_MODULE "Not all switches are connected in $TIME_WAIT seconds!! $_ERR"
		return 0
    fi
}

check_unidir_link() {
	_S1=$1
	_S2=$2
	_MODULE=$3
	_LOG=$4
	
	_FOUND=$(awk '/new link detected/ {print}' $_LOG | sed -e 's/://g;s/^0*//' | awk -v s1=$_S1 -v s2=$_S2 'BEGIN {count=0} {if ( substr($4, 2) == s1 && $7 == s2 ) count++} END {print count; print NR > ".line.link" }')

	_S1=$(echo $_S1 | sed 's/^0*//')
	_S2=$(echo $_S2 | sed 's/^0*//')

    if [ $_FOUND -eq 1 ]; then
    	print_msg $_MODULE "Link ( $_S1 --> $_S2 ) found!!!"
		return 1
    elif [ $_FOUND -gt 1 ]; then
    	print_warn $_MODULE "Link ( $_S1 --> $_S2 ) found $_FOUND times!!!"
		return 1
	else
        print_err $_MODULE "Link ( $_S1 --> $_S2 ) not found!!!"
		return 0
	fi
}

check_link() {
	S1=$1
	S2=$2
	_MODULE=$3
	_LOG=$4

	_CNT=0
	check_unidir_link $S1 $S2 $_MODULE $_LOG
	_CNT=$(echo "$_CNT+$?" | bc)
	check_unidir_link $S2 $S1 $_MODULE $_LOG
	_CNT=$(echo "$_CNT+$?" | bc)

	if [ $_CNT -eq 2 ]; then
		_CNT=1
	else
		# See uni directional link as there's no link
		_CNT=0
	fi

	return $_CNT
}

check_links() {
	_MODULE=$1
	_LOG=$2
	COUNT=$3
	TIME_WAIT=$4

	LINK_COUNT=0
	for (( k=1; k <= ${#links[@]}; k++)); do
		link=${links[$k]}

		sw_west=$(echo $link | awk '{print $1}')
		eval sw_west=$sw_west

		sw_east=$(echo $link | awk '{print $2}')
		eval sw_east=$sw_east

		check_link $sw_west $sw_east $_MODULE $_LOG
		LINK_COUNT=$(echo "$LINK_COUNT+$?" | bc)
	done

	if [ $LINK_COUNT -eq ${#links[@]} ]; then
	    print_info $_MODULE "All links found!!!"
	else
	    print_err $_MODULE "$LINK_COUNT / ${#links[@]} links found!!!"
	fi
}

get_nw_str() {
	DL_TYPE=$1
	NW_PROTO=$2

	nw_str=""
	if [ "$DL_TYPE" == "ARP" ]; then
		nw_str="arp"	
	elif [ "$DL_TYPE" == "IP" ]; then
		if [ $NW_PROTO -eq 1 ]; then
			nw_str="icmp"
		elif [ $NW_PROTO -eq 6 ]; then
			nw_str="tcp"
		elif [ $NW_PROTO -eq 17 ]; then
			nw_str="udp"
		fi
	fi
	echo $nw_str
}

check_action() {
	_MODULE=$1
	_LOG=$2
	TIME_WAIT=$3

    DPID=$(echo $_str | awk '{print $2}')
    DL_TYPE=$(echo $_str | awk '{print $6}')
    NW_PROTO=$(echo $_str | awk '{print $8}')
	NW_STR=$(get_nw_str $DL_TYPE $NW_PROTO)
    NW_SRC=$(echo $_str | awk '{print $10}')
    NW_DST=$(echo $_str | awk '{print $14}')
    SEARCH=$(echo $_str | awk '{ idx=index($0, "IN="); print substr($0, idx); }')
   	_mon=$(hget monitors $DPID)

    IFS=$'\n'
	_FT_INSTALLED=0
    len_action=$(grep ACTION= $_LOG | grep $DPID | grep "$SEARCH" | wc -l)
	if [ $len_action -eq 0 ]; then
		sleep 1
	else
		_ERR=$(awk 'BEGIN {c=0} /ROUTE: No route between/ { c=$0; print NR > ".skip.list" }; END {print c}' $_LOG)
		if [ "$_ERR" != "0" ]; then
			print_err $_MODULE "$_ERR"
        fi

    	  ACTION=$(grep ACTION= $_LOG | grep $DPID | grep "$SEARCH")
       	  for _action in $ACTION; do
			if [ $_FT_INSTALLED -eq 1 ]; then
				break;
			fi

    		ACT_SEARCH=$(echo $_action | awk '{ idx=index($0, "DPID="); print substr($0, idx); }')
			print_msg $_MODULE "$ACT_SEARCH"
        	for((i=0; i<$TIME_WAIT; i++)); do
    	    	if [ "$DPID" != "a90c0913435ef00" ]; then
    				_ft_cnt=$(ssh $_mon "dpctl dump-flows unix:/var/run/test" | grep $NW_STR | grep nw_src=$NW_SRC | grep nw_dst=$NW_DST | wc -l)
#_ft_cnt=$(ssh $_mon "dpctl dump-flows unix:/var/run/dp0.sock" | grep $NW_STR | grep nw_src=$NW_SRC | grep nw_dst=$NW_DST | wc -l)
    				if [ $_ft_cnt -gt 0 ]; then
						#ssh $_mon "dpctl dump-flows unix:/var/run/dp0.sock" | grep $NW_STR | grep nw_src=$NW_SRC | grep nw_dst=$NW_DST 
    					print_msg OFS "DPID= $DPID Flowtable entry installed - $DL_TYPE, $NW_PROTO, $NW_SRC, $NW_DST"
    					_FT_INSTALLED=1
    					break;
    				fi
        		else
    				_ft_cnt=$(dpctl dump-flows $_mon | grep $NW_STR | grep nw_src=$NW_SRC | grep nw_dst=$NW_DST | wc -l )
    				if [ $_ft_cnt -gt 0 ]; then
    					print_msg OFS "DPID= $DPID Flowtable entry installed - $DL_TYPE, $NW_PROTO, $NW_SRC, $NW_DST"
    					_FT_INSTALLED=1
    					#dpctl dump-flows $_mon | grep $NW_STR | grep nw_src=$NW_SRC | grep nw_dst=$NW_DST
    					break;
    				fi
       	 		fi
				sleep 1
        	done
		  done
	fi

	if [ $_FT_INSTALLED -eq 1 ]; then
		return 1
	fi

	return 0
}

check_pkts() {
	_MODULE=$1
	_LOG=$2
	TIME_WAIT=$3

    IFS=$'\n'
	_NOX_PROCESS=0
    for((i=0; i<$TIME_WAIT; i++)); do
		len_pktin=$(awk '/PKTIN/ { idx=index($0, "DPID="); print substr($0, idx); }' $_LOG | wc -l)

		if [ $len_pktin -eq 0 ]; then
			print_msg $_MODULE "Wait for new packets..."
			sleep 1
		else
			print_msg $_MODULE "New packets arrvied..."
			PKTIN=$(awk '/PKTIN/ { idx=index($0, "DPID="); print substr($0, idx); }' $_LOG)
    		for _str in $PKTIN; do
				print_warn $_MODULE $_str
				check_action $_MODULE $_LOG $TIME_WAIT
				if [ $? -eq 0 ]; then
					print_err $_MODULE "Cannot find flowtables..."
					_NOX_PROCESS=0
					break;
				else
					_NOX_PROCESS=1
				fi
    		done
		fi	

		if [ $_NOX_PROCESS -eq 1 ]; then
			print_info $_MODULE "Done!!!"
			break;
		fi
	done
}
