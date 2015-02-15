#!/bin/bash

OUTPUT=/tmp/queues.output
rabbitmqctl list_queues name durable auto_delete messages arguments > $OUTPUT

printf "%-80s %-10s %-10s %-10s %-10s\n" "name" "durable" "auto_delete" "messages" "arguments"
printf "================================================================================================================================================\n"

show_queue() {
	awk '
($1 !~ /Listing/) && ($1 !~ /...done/){
	printf("%-80s %-10s %-10s %-10s %-10s\n", $1, $2, $3, $4, $5);
}' $OUTPUT | sort
}

show_queue $queue
