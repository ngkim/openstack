#!/bin/bash

source "$PWD/openstackrc"

print_user_input() {
	printf '1 %20s -> %s\n' TEST_VM $TEST_VM
    printf '2 %20s -> %s\n' TEST_IMAGE $TEST_IMAGE
    printf '3 %20s -> %s\n' TEST_ZONE $TEST_ZONE
    printf '4 %20s -> %s\n' TEST_HOST $TEST_HOST
    printf '5 %20s -> %s\n' red_net $red_net
    printf '6 %20s -> %s\n' green_net $green_net
    printf '7 %20s -> %s\n' orange_net $orange_net
    printf '8 %20s -> %s\n' private_net $private_net
    printf '9 %20s -> %s\n' pub_net $pub_net
}

print_networks() {
	echo '# --------------------------------------------------------------------'
    printf '%20s -> %s\n' $red_net   	$RED_PUBLIC_NET_ID
    printf '%20s -> %s\n' $green_net  	$GREEN_VLAN_NET_ID
    printf '%20s -> %s\n' $orange_net 	$ORANGE_VLAN_NET_ID
    printf '%20s -> %s\n' $private_net 	$PRV_NET_ID
    printf '%20s -> %s\n' $pub_net 		$PUB_NET_ID    
    echo '# --------------------------------------------------------------------'
}

remove_vm_if_exists() {
	if [ $TEST_VM_ID ]; then
    	printf '%20s -> %s\n' $TEST_VM $TEST_VM_ID
    	echo '# --------------------------------------------------------------------'    
    
        printf "%s vm already exists so delete it !!!\n" $TEST_VM
        printf "nova delete %s\n" $TEST_VM
        nova delete $TEST_VM
    fi
}

print_nova_boot1() {
    echo "nova boot $TEST_VM
        --flavor 3
        --image $TEST_IMAGE
        --key-name $TEST_KEY
        --nic net-id=$GREEN_VLAN_NET_ID
        --nic net-id=$ORANGE_VLAN_NET_ID
        --nic net-id=$RED_PUBLIC_NET_ID
        --nic net-id=$PRV_NET_ID
        --availability-zone ${TEST_ZONE}:${TEST_HOST}
        --security-groups default"
}

print_nova_boot() {
    echo "nova boot $TEST_VM
        --flavor 3
        --image $TEST_IMAGE
        --key-name $TEST_KEY
        $STR_NIC
        --availability-zone ${TEST_ZONE}:${TEST_HOST}
        --security-groups default"
}

do_nova_boot() {
	print_nova_boot
	
	nova boot $TEST_VM --flavor 3 --image $TEST_IMAGE --key-name $TEST_KEY $STR_NIC --availability-zone ${TEST_ZONE}:${TEST_HOST} --security-groups default
}

do_nova_boot1() {
	nova boot $TEST_VM \
        --flavor 3 \
        --image $TEST_IMAGE \
        --key-name $TEST_KEY \
        --nic net-id=$GREEN_VLAN_NET_ID \
        --nic net-id=$ORANGE_VLAN_NET_ID \ 
        --nic net-id=$RED_PUBLIC_NET_ID \
        --nic net-id=$PRV_NET_ID \
        --availability-zone ${TEST_ZONE}:${TEST_HOST} \
        --security-groups default
}


add_nic() {
	C_BIT=$1
	N_BIT=$2
	NET_ID=$3
	NET_NAME=$4
	if (( $C_BIT & $N_BIT )); then
		echo "$NET_NAME= $NET_ID" 
		STR_NIC="$STR_NIC--nic net-id=$NET_ID "
	fi
}

make_customer_vm()
{
    echo '
    ################################################################################
        make_customer_vm !!!
    ################################################################################
    '
    TEST_VM=$1
    TEST_IMAGE=$2
    TEST_ZONE=$3
    TEST_HOST=$4
    
    NW_BIT=$5
    
    red_net=$6
    green_net=$7
    orange_net=$8
    private_net=$9
    
    pub_net=$PUBLIC_NET

	print_user_input

    TEST_TENANT_ID=$(keystone tenant-list | grep "${TEST_TENANT_NAME} " | awk '{print $2}')
    TEST_IMAGE_ID=$(nova image-list | grep "$TEST_IMAGE " | awk '{print $2}')

    echo '# --------------------------------------------------------------------'
    printf '%20s -> %s\n' TEST_TENANT_NAME $TEST_TENANT_ID
    printf '%20s -> %s\n' TEST_IMAGE  $TEST_IMAGE_ID
    printf '%20s -> %s\n' TEST_KEY $TEST_KEY
                 
    RED_PUBLIC_NET_ID=$(neutron net-list | grep "$red_net " | awk '{print $2}')
    GREEN_VLAN_NET_ID=$(neutron net-list | grep "$green_net " | awk '{print $2}')
    ORANGE_VLAN_NET_ID=$(neutron net-list | grep "$orange_net " | awk '{print $2}')
    PRV_NET_ID=$(neutron net-list | grep "$private_net " | awk '{print $2}')
    PUB_NET_ID=$(neutron net-list | grep "$pub_net " | awk '{print $2}')

	print_networks 
	
	STR_NIC=""
	echo "NW_BIT= "$NW_BIT
	let "nw_bit_green=2#0001"
	let "nw_bit_orange=2#0010"
	let "nw_bit_red=2#0100"
	let "nw_bit_test=2#1000"
	add_nic $NW_BIT $nw_bit_test $PRV_NET_ID "PRIVATE NET"
	add_nic $NW_BIT $nw_bit_green $GREEN_VLAN_NET_ID "GREEN_VLAN"
	add_nic $NW_BIT $nw_bit_orange $ORANGE_VLAN_NET_ID "ORANGE_VLAN"
	add_nic $NW_BIT $nw_bit_red $RED_PUBLIC_NET_ID "RED_PUBLIC_VLAN"
	echo "STR_NIC= $STR_NIC"
	
	TEST_VM_ID=$(nova list | grep "$TEST_VM " | awk '{print $2}')
    remove_vm_if_exists
    
    # go_stop
    do_nova_boot
}

REGION=RegionOne
ADMIN_TENANT_ID=$(keystone tenant-list | awk '/\ admin\ / {print $2}')
ADMIN_TENANT_NAME=forbiz
PUBLIC_NET=public_net
PUBLIC_SUBNET=public_subnet

TEST_TENANT_NAME=forbiz
TEST_USER_NAME=admin
TEST_USER_PASS=ohhberry3333
TEST_NET=forbiz_guest_net
TEST_SUBNET=forbiz_guest_subnet 

TEST_KEY=testkey
TEST_KEY_FILE=testkey.pub
TEST_IMAGE=ubuntu-12.04

# red shared network info
RED_PUBLIC_NET=red_shared_public_net

# green network info
GREEN_VLAN1_NET=forbiz_green_net

# orange network info
ORANGE_VLAN1_NET=forbiz_orange_net

TEST_NET=forbiz_guest_net
TEST_SUBNET=forbiz_guest_subnet

PUBLIC_NET=public_net
PRIVATE_PHYSNET_NAME=physnet_guest

let "nw_bit=2#1011"
make_customer_vm \
    ubuntu_utm ubuntu-12.04 seocho.seoul.zo.kt havana \
    $nw_bit $RED_PUBLIC_NET $GREEN_VLAN1_NET $ORANGE_VLAN1_NET $TEST_NET $PUB_NET

#let "nw_bit=2#1010"
#make_customer_vm \
#    forbiz_orange1 ubuntu-12.04 seocho.seoul.zo.kt cnode02 \
#    $nw_bit $RED_PUBLIC_NET $GREEN_VLAN1_NET $ORANGE_VLAN1_NET $TEST_NET $PUB_NET    
