#!/bin/bash

source "$MNG_ROOT/include/print.sh"

rm -rf dump
mkdir -p dump

for dev in `cat list-ports.br-int`; do
	print_info "DEVLIST" $dev
	tcpdump -i $dev -ne -l -c 30 &> dump/$dev.dump &
done
sleep 10
