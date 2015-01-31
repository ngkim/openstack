#!/bin/bash


mode=$1

function usage() {
 
    echo "
    usage:: vm_console_log.sh mode(ex:cat, cat|more ..)
      ex) vm_console_log.sh 
      ex) vm_console_log.sh cat
      ex) vm_console_log.sh cat | more
    "   
}

function list_vm() {
    nova list
    
    MY_PROMPT="# select any vm to watch console log -> ?? "
    while :
    do
       echo -n "$MY_PROMPT"
       read line       
       if [ $line ]
       then
           echo "selected vm: $line"
           select_vm $line
           check_vm $line
           check_logfile $vm_id
           run
       else
           usage
           exit
       fi  
    done
}

function select_vm() {
    
    vm=$1
    
	if [ $vm ]
	then
	    echo "# ----------------------------------------------------------------"
	    echo " [$vm] console_log tailing"
	    echo " this command should be run on cnode where vm is running.."    
	    echo "# ----------------------------------------------------------------"
	else
	    echo "
	        usage:: vm_console_log.sh vm_name mode(ex:cat, cat|more ..)
	          ex) vm_console_log.sh ubuntu-12.04
	          ex) vm_console_log.sh ubuntu-12.04 cat
	          ex) vm_console_log.sh ubuntu-12.04 cat | more
	        "
	    exit
	fi

}

function check_vm() {
    vm=$1
	vm_id=$(nova list | grep "$vm " | awk '{print $2}')
	
	if [ $vm_id ]
	then
	    echo "# ----------------------------------------------------------------"
	    echo "vm_name[${vm}] -> vm_id[${vm_id}]"    
	    echo "# ----------------------------------------------------------------"
	else
	    echo "# ----------------------------------------------------------------"
	    echo "vm_name[${vm}] does not exist on this host !!!"    
	    echo "# ----------------------------------------------------------------"
	    exit
	fi
}

function check_logfile() {
    vm_id=$1
	file=/var/lib/nova/instances/$vm_id/console.log
	if [ -f $file ]
	then
	    echo "# ----------------------------------------------------------------"
	    echo "file[${file}] exists"    
	    echo "# ----------------------------------------------------------------"
	else
	    echo "# ----------------------------------------------------------------"
	    echo "file[${file}] does not exist on this host !!!"    
	    echo "# ----------------------------------------------------------------"
	    exit
	fi
}

function run() {
	if [ $mode ]
	then
	    $mode $file
	else        
	    tail -f $file
	fi
}

list_vm
