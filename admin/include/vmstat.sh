#!/bin/bash

source "$MNG_ROOT/include/print.sh"
source "$MNG_ROOT/include/process.sh"

log_vmstat() {
	vmstat -n 1
}

start_log_vmstat() {
	LOG_=$1

	print_info "VMSTAT" "Start logging VMSTAT..." 
	log_vmstat &> $LOG_ &
}

stop_log_vmstat() {
	print_info "VMSTAT" "Stop logging VMSTAT..." 
	kill_local_processes vmstat
}

# get cpu usage from vmstat log
get_cpu_usage() {
	_LOG=$1

	awk '
		BEGIN{
			count=0; sy=0; us=0; sum=0; total=0;
			printf("      cpu    sy    us\n"); 
		}
		{
			if ( $1 !~ /^[0-9]*$/ ) { next }
			sy=$13; us=$14; sum=sy+us; total+=sum; count++;
			printf("%4d %4d %5s %5s\n", count, sum, $13, $14)
		}
		END {
			avg=total/count;
			printf("Average= %.2f total= %d count= %d\n", avg, total, count)
		}
	' $_LOG
}

# get interrupt and context switch count from vmstat log
get_intr_ctxt() {
	_LOG=$1

	awk '
		BEGIN{
			i=1; 
			printf("       int    cs\n"); 
		}
		{
			if ( $1 !~ /^[0-9]*$/ ) { next }
			printf("%4d %5s %5s\n", i++, $11, $12)
		}
	' $_LOG
}
