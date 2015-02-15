#!/bin/bash

source "$MNG_ROOT/include/print.sh"

procurve_of_start () {
	SWITCH=$1
	VLAN=$2

	print_title_small " Enable OpenFlow of VLAN $VLAN at $SWITCH"
	snmpset -v2c -c public $SWITCH iso.org.dod.internet.private.enterprises.11.2.14.11.5.1.7.1.35.1.1.2.$VLAN i 1
}

procurve_of_stop () {
	SWITCH=$1
	VLAN=$2

	print_title_small " Disable OpenFlow of VLAN $VLAN at $SWITCH"
	snmpset -v2c -c public $SWITCH iso.org.dod.internet.private.enterprises.11.2.14.11.5.1.7.1.35.1.1.2.$VLAN i 2
}

procurve_of_restart() {
	SWITCH=$1
	VLAN=$2

	procurve_of_disable $SWITCH $VLAN
	sleep 3
	procurve_of_enable $SWITCH $VLAN
}

procurve_of_status() {
	SWITCH=$1
	VLAN=$2

	print_title_small " OpenFlow status of VLAN $VLAN at $SWITCH"
	echo "     - 1: enable"
	echo "     - 2: disable"
	snmpwalk -v2c -c public $SWITCH iso.org.dod.internet.private.enterprises.11.2.14.11.5.1.7.1.35.1.1.2.$VLAN
}
