is_netopen_switch_created() {
	_LOG=$1
	
	RET=0
	RET=$(awk 'BEGIN{ created=0; } /unix:/ { idx=index($0, "connected"); if (idx != 0) {created=1;}} END { print created; }' $_LOG)
	echo $RET
}

is_netopen_switch_connected() {
	_LOG=$1

	RET=0
	RET=$(awk 'BEGIN{ created=0; } /tcp:/ { idx=index($0, "connected"); if (idx != 0) {created=1;}} END { print created; }' $_LOG)

	echo $RET
}


