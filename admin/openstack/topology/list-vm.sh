#!/bin/bash

VM_LIST=`virsh list | awk '$1 ~ /^[0-9]+$/{print $2}'`

NOVA_USER="nova"
NOVA_PASS="nova"
NOVA_DB="nova"
DB_HOST="127.0.0.1"

# prerequisite: jq
jq 2> /dev/null
if [ $? -eq 127 ]; then
  apt-get -y install jq
fi

get_mac() {
	vm=$1
	ITF=$2

	MAC=`virsh domiflist $vm | awk '$1 ~ /'$ITF'/ {print $5}'`
	
	echo $MAC
}

get_br() {
	vm=$1
	ITF=$2

	BR_NAME=`virsh domiflist $vm | awk '$1 ~ /'$ITF'/ {print $3}'`

	echo $BR_NAME
}

get_br_dev_list() {
	BR_NAME=$1

	BR_LIST=`ls /sys/class/net/$BR_NAME/brif`

	echo $BR_LIST
}

get_veth_in_qbr() {
	dev_tap=$1
	# should set qbr_dev_list before calling get_veth_in_qbr
	for dev in $qbr_dev_list; do
		if [ "$dev" != "$dev_tap" ]; then
			dev_qvb=$dev
		fi
	done
	
	echo $dev_qvb
}

get_dev_id() {
	dev_tap=$1

	echo $dev_tap | sed 's/tap//'
}

get_dev_qvo_name() {
	dev_id=$1

	echo "qvo${dev_id}"
}

get_ovs_list_ports() {
	ovs=$1

	ovs-vsctl list-ports $ovs
}

get_vm_num() {
	vm_id=$1
	echo $vm_id | sed -e 's/instance-//'
}

get_vm_num_to_digit() {
	vm_num=$1

	printf "%d" "0x$vm_num"
}

get_vm_name() {
	vm_id_num=$1
	
	QUERY_FILE=$PWD/.sql
	
	echo "select hostname,uuid from instances where id = '"$vm_id_num"';" > $QUERY_FILE

	rs=`mysql -u $NOVA_USER -p$NOVA_PASS -h $DB_HOST $NOVA_DB < $QUERY_FILE  | awk '{if (NR!=1){print}}'`
	
	vm_name=`echo $rs | awk '{print $1}'`
	vm_uuid=`echo $rs | awk '{print $2}'`
}

get_interface_ip() {
	vm_uuid=$1
	vm_mac=$2
	
	# nova interface-list를 이용하면 너무 시간이 오래걸림
	# vm_ip=`nova interface-list $vm_uuid | awk '/$vm_mac/{print $0}'`
	
	# 직접 db를 query
	QUERY_FILE=$PWD/.ip.sql
	echo "select network_info from instance_info_caches where instance_uuid = '"$vm_uuid"';" > $QUERY_FILE
	
	rs=`mysql -u $NOVA_USER -p$NOVA_PASS -h $DB_HOST $NOVA_DB < $QUERY_FILE  | awk '{if (NR!=1){print}}'`
	vm_ip_list=`echo $rs | jq '.[] | {mac: .address, ip: .network.subnets[0].ips[0].address}'`
	
	# select에 vm_mac 값이 전달되지 않음 ==> 다른 방법을 찾아야 함
	# ip와 mac을 list로 받아 mac이 일치하는 경우, 해당 인덱스의 ip를 반환
	vm_ips=`echo $vm_ip_list | jq '.ip' | tr -d '\"'`
	vm_macs=`echo $vm_ip_list | jq '.mac' | tr -d '\"'`
	
	cnt=1
	for mac in $vm_macs; do
		if [ $mac == $vm_mac ]; then
			vm_ip=`echo $vm_ips | awk '{print $'$cnt'}'`
			#echo "vm_mac= $mac cnt= $cnt vm_ip= $vm_ip"
		fi
		let cnt=cnt+1
	done
	
	echo $vm_ip
}

blue=$(tput setaf 4)
green=$(tput setaf 2)
red=$(tput setaf 1)
normal=$(tput sgr0)

# store dev_qvo to check if it's in br-int
list_dev_qvo=""
for vm in $VM_LIST; do
	vm_num=$(get_vm_num $vm)
	#echo "vm=" $vm "vm_num=" $vm_num	
	vm_id_num=`get_vm_num_to_digit $(get_vm_num $vm)`
	get_vm_name $vm_id_num
	printf "${red}$vm_name${normal}\n"
	
	IF_LIST=`virsh domiflist $vm | awk '$1 ~ /^tap/ {print $1}'`
	for iftap in $IF_LIST; do
		dev_id=$(get_dev_id $iftap)
		MAC=$(get_mac $vm $iftap)
		dev_ip=$(get_interface_ip $vm_uuid $MAC)
		qbr=$(get_br $vm $iftap)
		qbr_dev_list=$(get_br_dev_list $qbr) 
		dev_qvb=$(get_veth_in_qbr $iftap)
		dev_qvo=$(get_dev_qvo_name $dev_id)
		list_dev_qvo="$list_dev_qvo $dev_qvo"
		
		if [ -z $dev_ip ]; then
			printf "\t%10s %-20s %10s %-20s %10s %-20s %10s %-20s\n" \
					${blue}DEV_TAP= ${normal}$iftap \
					${blue}BR_Q= ${normal}$qbr \
					${blue}DEV_QVB= ${normal}$dev_qvb \
					${blue}DEV_QVO= ${normal}$dev_qvo
		else
			printf "\t%10s %-20s %10s %-20s %10s %-20s %10s %-20s %10s %-20s\n" \
					${blue}DEV_IP= ${normal}$dev_ip \
					${blue}DEV_TAP= ${normal}$iftap \
					${blue}BR_Q= ${normal}$qbr \
					${blue}DEV_QVB= ${normal}$dev_qvb \
					${blue}DEV_QVO= ${normal}$dev_qvo			
		fi
	
		
	done
done

if [[ "$HOST" =~ ^user.* ]]; then
    echo "yes"
fi

dev_list_contains_port() {
	port=$1	

	for dev in $list_dev_qvo; do
		if [ $dev == $port ]; then
			echo "$dev"
			break
		fi
	done
}

print_dev_qvo_in_br_int() {
	port=$1
    idx=$2

	dev_qvo=$(dev_list_contains_port $port)
	dev_qvo=$(echo $dev_qvo | tr -d '\n' | tr -d ' ')

	char_cnt=$(echo $dev_qvo | wc -m)
	if [ $char_cnt -gt 1 ]; then
		tag=`python get_vlan_tag.py $dev_qvo`
		printf "\t%5s %-15s %5s\n" $idx $dev_qvo $tag
    	idx=`expr $idx + 1`
	fi
}

print_dev_int_in_br_int() {
	port=$1
    idx=$2

	if [[ $port =~ ^[int] ]]; then
		tag=`python get_vlan_tag.py $port`
		printf "\t%5s %-15s %5s\n" $idx $port $tag
		idx=`expr $idx + 1`
	fi
}

print_dev_phy_in_br() {
	port=$1

	if [[ $port =~ ^[phy] ]]; then
		printf "\t$port\n"
	fi
}

list_dev_phy_in_br() {
	port=$1

	if [[ $port =~ ^[phy] ]]; then
		printf "\t$port\n"
	fi
}

ovs="br-int"
printf "${red}$ovs${normal}\n"
port_list=$(get_ovs_list_ports $ovs)

idx=1
printf "\t%5s %-15s %5s\n" "seq" "name" "tag"
for port in $port_list; do
	print_dev_qvo_in_br_int $port $idx
	print_dev_int_in_br_int $port $idx
done

OVS_LIST=`ovs-vsctl list-br`
for ovs in $OVS_LIST; do
	if [ "$ovs" == "br-int" ]; then
		continue;
	fi
	printf "${red}$ovs${normal}\n"
	port_list=$(get_ovs_list_ports $ovs)
	for port in $port_list; do
		printf "\t$port\n"
	done
done
