source "$MNG_ROOT/include/print.sh"

set_noflood() {
	HOST=$1
	ITF=$2
    SOCK=$3

	print_info noflood "$HOST set $ITF noflood"
	ssh $HOST "dpctl mod-port unix:/var/run/$SOCK $ITF noflood"
}

set_noflood_all() {
	for (( k = 1; k <= ${#noflood[@]}; k++ )); do 
		_host=$(echo ${noflood[$k]} | awk '{print $1}')
		_intf=$(echo ${noflood[$k]} | awk '{print $2}')
		_sock=$(echo ${noflood[$k]} | awk '{print $3}')
       set_noflood $_host $_intf $_sock
	done
}

set_flood() {
	HOST=$1
	ITF=$2
    SOCK=$3

	print_info noflood "$HOST set $ITF flood"
	ssh $HOST "dpctl mod-port unix:/var/run/$SOCK $ITF flood"
}

set_flood_procurve() {
    SOCK=$1
	ITF=$2

	print_info noflood "$SOCK set $ITF flood"
	dpctl mod-port $SOCK $ITF flood
}

set_noflood_procurve() {
    SOCK=$1
	ITF=$2

	print_info noflood "$SOCK set $ITF noflood"
	dpctl mod-port $SOCK $ITF noflood
}

get_noflood() {
	HOST=$1
	ITF=$2
    SOCK=$3

	print_info noflood "Show datapath - $HOST "
	ssh $HOST "dpctl show unix:/var/run/$SOCK"
}

get_noflood_procurve() {
    SOCK=$1
	ITF=$2

	print_info noflood "Show datapath - $SOCK "
	dpctl show $SOCK
}
