#!/bin/bash

# bindinginfo는 exchange와 queue사이의 연결 관계를 보여준다.

#<bindinginfoitem> must be a member of the list 
#[source_name, source_kind, destination_name, destination_kind, routing_key, arguments]

_OUTPUT=/tmp/bindings.output.1
OUTPUT=/tmp/bindings.output
#rabbitmqctl list_bindings source_name source_kind destination_name destination_kind routing_key arguments > $_OUTPUT
rabbitmqctl list_bindings source_name source_kind destination_name destination_kind routing_key > $_OUTPUT

# replace leading white spaces with '0'
cat $_OUTPUT | sed "s/^[\t]/0 /" > $OUTPUT

show_binding() {
	#printf "%-70s %-80s %-10s %-10s\n" "exchange" "queue" "routing_key" "arguments"
	printf "%-50s %-80s %-10s\n" "exchange" "queue" "routing_key"
	printf "================================================================================================================================================\n"

	awk '
($1 !~ /Listing/) && ($1 !~ /^...done/){
	printf("%-50s %-80s %-10s\n", $1, $3, $5);
}' $OUTPUT | sort
}

show_binding
