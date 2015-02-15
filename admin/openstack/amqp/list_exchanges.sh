#!/bin/bash

OUTPUT=/tmp/exchanges.output
rabbitmqctl list_exchanges name type durable auto_delete internal arguments > $OUTPUT

printf "%-70s %-10s %-10s %-10s %-10s %-10s\n" "name" "type" "durable" "auto_delete" "internal" "arguments"
printf "================================================================================================================================================\n"

show_exchange() {
	NAME=$1

	awk '
$2 ~ /'$NAME'/ {
	printf("%-70s %-10s %-10s %-10s %-10s %-10s\n", $1, $2, $3, $4, $5, $6);
}' $OUTPUT | sort
}

LIST_EXCHANGE="headers topic fanout direct"
for exchange in $LIST_EXCHANGE; do
	show_exchange $exchange
	printf "\n"
done

#awk '
#$2 ~ /fanout/ {
#	printf("%-70s %-10s %-10s %-10s %-10s %-10s\n", $1, $2, $3, $4, $5, $6);
#}' $OUTPUT
#awk '
#$2 ~ /topic/ {
#	printf("%-70s %-10s %-10s %-10s %-10s %-10s\n", $1, $2, $3, $4, $5, $6);
#}' $OUTPUT
#awk '
#$2 ~ /direct/{
#	printf("%-70s %-10s %-10s %-10s %-10s %-10s\n", $1, $2, $3, $4, $5, $6);
#}' $OUTPUT
