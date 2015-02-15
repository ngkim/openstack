no_urn() {
	print_err foam "No Sliver URN!!!"
	exit -1
}

get_rspec() {
	for (( i=1; i <= ${#rspecs[@]}; i++ )); do
		_s_name=$(echo ${rspecs[$i]} | awk '{print $1}')
		_s_spec=$(echo ${rspecs[$i]} | awk '{print $2}')
		if [ "$SLICE_NAME" == "$_s_name" ]; then
			echo $_s_spec
			break;
		fi
	done
}

list_slivers() {
	echo "foamctl list-slivers"
	ssh $AM_SERVER "foamctl list-slivers --passwd-file=/home/xgist/passwd" | awk 'BEGIN {urn=""; del=""; stat=""; desc=""; } /desc/ {desc=$0} /status/ {stat=$0} /sliver_urn/ {urn=$0} /deleted/ {del=$0} / }/ { printf("\033[1;31m%s\033[0m\n%s\n%s\n%s\n", urn, desc, stat, del); urn=""; stat=""; del=""; desc="" }'
}

get_pending_sliver_urn() {
	SLICE_NAME=$1

    ssh $AM_SERVER "foamctl list-slivers --passwd-file=/home/xgist/passwd" | awk -v s="$SLICE_NAME" 'BEGIN {urn=""; pending=0; found=0 } /Pending/ { pending=1 } /sliver_urn/ {urn=$2; if ( index($0, s) != 0 ) found=1; sub(/^"/, "", urn); sub(/",$/, "", urn); } / }/ { if( found == 1 && pending == 1) printf("%s", urn); urn=""; pending=0; found=0 }'
}
