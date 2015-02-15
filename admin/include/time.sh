#!/bin/bash

get_time() {
	date '+%s'
}

get_duration() {
	START=$1

	END=$(get_time)

	DUR=`expr $END - $START`
	
	echo $DUR
}

test_duration() {
	START=$(get_time)
	sleep 5

	echo $(get_duration $START)
}
