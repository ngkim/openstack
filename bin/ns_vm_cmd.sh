#!/bin/bash


# LJG: 모든 아큐먼트를 하나의 변수에 할당
command=$@

echo "
# --------------------------------------------------------------------------
#   !!! namespace를 이용한 vm 명령유틸 !!!
# --------------------------------------------------------------------------
#    우리가 openstack을 사용하면서 VM에 명령을 수행해야 할 때
#    vm 이름만 주면 해당 vm이 사용하는 qrouter or qdhcp를 찾아서 
#    \"ip netns exec <vm-dhcp> command\" 형식으로 명령을 수행하는 프로그램
#    
#    ex) ns_vm_cmd.sh ubuntu ping 10.10.10.1
#      -> ip netns exec <vm-dhcp> ping 10.10.10.1
#    ex) ns_vm_cmd.sh ubuntu ifconfig
#      -> ip netns exec <vm-dhcp> ifconfig  
# --------------------------------------------------------------------------
"

function usage() {
 
    echo "
# --------------------------------------------------------------------------
 vm을 입력하면 ip netns exec <vm-router> command 를 실행한다.
# --------------------------------------------------------------------------
usage:: ns_vm_cmd.sh vm_name command
  ex) ns_vm_cmd.sh ubuntu ping 10.10.10.1
      -> ip netns exec <vm-router> ping 10.10.10.1
  ex) ns_vm_cmd.sh ubuntu ifconfig
      -> ip netns exec <vm-router> ifconfig
# --------------------------------------------------------------------------
"
   
}

echo "
# --------------------------------------------------------------------------
    command -> [$command]
# --------------------------------------------------------------------------
"

usage

echo "neutron router-list"
neutron router-list

echo "neutron subnet-list"
neutron subnet-list

echo "ip netns"
ip netns

echo "nova list"
nova list



exit

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
