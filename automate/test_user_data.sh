#!/bin/bash

echo "
################################################################################
#
#   make vm on Private Network Test
#
################################################################################
"

source ./common.sh

export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=ohhberry3333
export OS_AUTH_URL=http://controller:5000/v2.0/
export OS_NO_CACHE=1

REGION=regionOne
ADMIN_TENANT_ID=$(keystone tenant-list | awk '/\ admin\ / {print $2}')
ADMIN_TENANT_NAME=admin
PUBLIC_NET=public_net

TEST_TENANT_NAME=admin
TEST_NET=guest_net
TEST_SUBNET=guest_subnet

TEST_KEY=testkey
TEST_KEY_FILE=testkey.pub
TEST_IMAGE=endian_community
TEST_IMAGE=ubuntu-12.04

#TEST_ZONE=east.dj.zo.kt
#TEST_HOST=cnode01
TEST_ZONE=seocho.seoul.zo.kt
TEST_HOST=havana

TEST_VM1=cnode02-1
TEST_VM2=cnode02-2



make_test_vm()
{
    echo '
    ################################################################################
        3. test vm 생성[private, green, orange nic 설정] !!!
    ################################################################################
    '

    TEST_VM=$1
    TEST_IMAGE=$2
    user_data_file=$3

    TEST_TENANT_ID=$(keystone tenant-list | grep "${TEST_TENANT_NAME} " | awk '{print $2}')
    TEST_IMAGE_ID=$(nova image-list | grep "$TEST_IMAGE " | awk '{print $2}')
    TEST_NET_ID=$(neutron net-list | grep "$TEST_NET " | awk '{print $2}')

    printf '\n######################################\n'
    printf '# [%s] vm 생성 => [%s] networks 연결\n' $TEST_VM $TEST_NET
    printf 'TEST_NET         %s -> %s\n' $TEST_NET  $TEST_NET_ID
    echo "TEST_TENANT($TEST_TENANT_NAME) ID: $TEST_TENANT_ID"
    echo "TEST_IMAGE($TEST_IMAGE) ID : $TEST_IMAGE_ID"
    echo "TEST_KEY      : $TEST_KEY"



    get_vm_id _vm_id $TEST_VM
    TEST_VM_ID=$_vm_id
    
    if [ $TEST_VM_ID ]
        then
            printf "%s vm already exists so delete it !!!\n" $TEST_VM
            printf "nova delete %s\n" $TEST_VM
            nova delete $TEST_VM
    fi

    echo "
    nova boot $TEST_VM
        --flavor 3
        --image $TEST_IMAGE_ID
        --key-name $TEST_KEY
        --nic net-id=$TEST_NET_ID
        --security-groups default
        --user-data $user_data_file"
        
        # --availability-zone ${TEST_ZONE}:${TEST_HOST}

    nova boot $TEST_VM \
        --flavor 3 \
        --image $TEST_IMAGE_ID \
        --key-name $TEST_KEY \
        --nic net-id=$TEST_NET_ID \
        --security-groups default \
        --user-data $user_data_file 
        
        # --availability-zone ${TEST_ZONE}:${TEST_HOST}
}

make_test_vm  uesr_data_vm ubuntu-12.04 ./bootscript.sh

