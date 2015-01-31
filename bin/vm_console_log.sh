#!/bin/bash

vm=$1
mode=$2

if [ $vm ]
then
    echo "######################################################################"
    echo " [$vm] console_log tailing"
    echo " this command should be run on cnode where vm is running.."    
    echo "######################################################################"
else
    echo "
        usage:: vm_console_log.sh vm_name mode(ex:cat, cat|more ..)
          ex) vm_console_log.sh ubuntu-12.04
          ex) vm_console_log.sh ubuntu-12.04 cat
          ex) vm_console_log.sh ubuntu-12.04 cat | more
        "
    exit
fi


vm_id=$(nova list --all-tenants | grep "$vm " | awk '{print $2}')

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


if [ $mode ]
then
    $mode $file
else        
    tail -f $file
fi


