#!/bin/bash

# ------------------------------------------------------------------------------
#LJG: 내가 쉘프로그래밍 초보자라 많은 시행착오가 있슴.
#    0. utf-8 사용에 따라 한글 깨짐 -> 에디터에서 utf-8로 변환하여 저장할 것
#    1. 라인끝에 공백이 들어가 있으면 에러가 발생 -> 도구로 문장끝 공백삭제 추천
#    2. ',과 " 짝 맞추기 -> bash 문법 systax 지원하는 에디터 사용 추천
#        ex) '~~", "~~' 이런예 많이 생김 ㅋㅋ
#    3. 함수안에서 ()사용하면 안됨 -> []를 사용해야 함. 아마 함수로 착각하는 듯
#    4. awk, grep 에서 정확하게 하나만 찾아지게 하려면 "$var "처럼 끝에 빈칸을 하나 넣어준다.
#       ex) awk "/${TEST_IMAGE} / {print $2}" or grep "$TEST_IMAGE "
# ------------------------------------------------------------------------------

# LJG:  잘못된 VM 을 DB에서 삭제하는 법
#       연결고리(FK)를 찾아서 하부테이블에서 부터 삭제해 나가야 함
# 1. instance_actions_events -> action_id     <-> instance_actions.id
# 2. instance_actions        -> instance_uuid <-> instances.id
# 3. instance_info_caches    -> instance_uuid <-> instances.id
# 4. instance_system_metadata-> instance_uuid <-> instances.id
# 5. instance


# LJG: cnode 주요 디렉토리: 아래 디렉토리들의 역할이 무엇인지 분석하자!!!
#   /var/lib/nova/instances
#   /etc/libvirt/qemu
#   /var/run/libvirt/qemu

################################################################################

good_sample() {
	
	INSTANCE_TYPE="nova flavor-list | head -n 4"
	# +----+-----------+-----------+------+-----------+------+-------+-------------+-----------+
	# | ID | Name      | Memory_MB | Disk | Ephemeral | Swap | VCPUs | RXTX_Factor | Is_Public |
	# +----+-----------+-----------+------+-----------+------+-------+-------------+-----------+
	# | 1  | m1.tiny   | 512       | 1    | 0         |      | 1     | 1.0         | True      |
	
	INSTANCE_TYPE="nova flavor-list | head -n 4 | tail -n 1"
	# | 1  | m1.tiny   | 512       | 1    | 0         |      | 1     | 1.0         | True      |
	
	INSTANCE_TYPE="nova flavor-list | head -n 4 | tail -n 1 | cut -d"|" -f2"
	# 1
}

#
# LJG: test계정을 만들기 위해서 처음에는 admin 환경으로 CLI 사용

export OS_AUTH_URL=http://10.0.0.101:5000/v2.0
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=ohhberry3333

TEST_TENANT_NAME=test_tenant
TEST_USER_NAME=test_user
TEST_USER_PASS=test_user
TEST_ROLE_NAME=test_role

make_test_customer()
{
    echo '
    ################################################################################
        1. customer tenant(test)/user(test) 생성 및 role(member) 추가 !!!
    ################################################################################
    '
    
    TEST_TENANT_ID=$(keystone tenant-list | grep "$TEST_TENANT_NAME " | awk '{print $2}')
    if [ $TEST_TENANT_ID ]
        then
            echo "$TEST_TENANT_NAME tenant already exists !!!" 
        else
            echo "keystone tenant-create --name $TEST_TENANT_NAME"
            keystone tenant-create --name $TEST_TENANT_NAME
    fi
    
    TEST_USER_ID=$(keystone user-list --tenant $TEST_TENANT_NAME | grep "$TEST_USER_NAME " | awk '{print $2}')
    if [ $TEST_USER_ID ]
        then
            echo "$TEST_USER_NAME user already exists !!!" 
        else
            echo "keystone user-create --name $TEST_USER_NAME --tenant $TEST_TENANT_NAME --pass $TEST_USER_PASS --enabled true"
            keystone user-create --name $TEST_USER_NAME --tenant $TEST_TENANT_NAME --pass $TEST_USER_PASS --enabled true
    fi
    
    TEST_ROLE_ID=$(keystone user-role-list --tenant $TEST_TENANT_NAME | grep "$TEST_ROLE_NAME " | awk '{print $2}')
    if [ $TEST_ROLE_ID ]
        then            
            echo "$TEST_ROLE_NAME user-role already exists !!!"
        else
        	TEST_ROLE_ID=$(keystone role-list | grep "$TEST_ROLE_NAME " | awk '{print $2}')
        	if [ $TEST_ROLE_ID ] 
        	then
        		echo "keystone role $TEST_ROLE_NAME exists !!!"
        	else
        		echo "keystone role-create --name $TEST_ROLE_NAME"
        		keystone role-create --name $TEST_ROLE_NAME
        	fi        	
        	
            echo "keystone user-role-add --tenant $TEST_TENANT_NAME --user $TEST_USER_NAME --role $TEST_ROLE_NAME"
            keystone user-role-add --tenant $TEST_TENANT_NAME --user $TEST_USER_NAME --role $TEST_ROLE_NAME 
    fi
    
}

function get_tenant_id() {

    # use call by ref 방법: 소스가 훨씬 깔끔해짐.

    # usage: get_tenant_id _tenant_id tenant_name
    #        echo "result -> <$_tenant_id>"

    local  _result_ptr=$1
    local  local_result

    tenant_name=$2
    tenant_id=$(keystone tenant-list | grep "$tenant_name " | awk '{print $2}')
    
    
    printf "tenant_name[%s] -> tenant_id[%s]\n" $tenant_name $tenant_id
    local_result=$tenant_id

    #original ->  eval $_result_ptr="'$local_result'"
    eval $_result_ptr=$local_result
}

function get_vm_id() {

    # usage: get_vm_id _vm_id vm_name
    #        echo "result -> <$_vm_id>"

    local _result_ptr=$1

    vm_name=$2
    vm_id=$(nova list | grep "$vm_name " | awk '{print $2}')
    printf "vm_name[%s] -> vm_id[%s]\n" $vm_name $vm_id

    eval $_result_ptr=$vm_id
}

# TEST_NET_ID=$(neutron net-list | grep "$TEST_NET " | awk '{print $2}')
function get_net_id() {

    # usage: get_net_id _net_id net_name
    #        echo "result -> <$_net_id>"

    local _result_ptr=$1

    net_name=$2
    net_id=$(neutron net-list | grep "$net_name " | awk '{print $2}')
    printf "net_name[%s] -> net_id[%s]\n" $net_name $net_id

    eval $_result_ptr=$net_id
}

# TEST_SUBNET_ID=$(neutron subnet-list --tenant $TEST_TENANT_NAME | grep "$TEST_SUBNET " | awk '{print $2}')
function get_subnet_id() {

    # usage: get_subnet_id _subnet_id tenant_name subnet_name
    #        echo "result -> <$_subnet_id>"

    local _result_ptr=$1

    tenant_name=$2
    subnet_name=$3
    
    subnet_id=$(neutron subnet-list --tenant $tenant_name | grep "$subnet_name " | awk '{print $2}')
    printf "tenant_name[%s], subnet_name[%s] -> subnet_id[%s]\n" $tenant_name $subnet_name $subnet_id

    eval $_result_ptr=$subnet_id
}

# TEST_ROUTER_ID=$(neutron router-list --tenant $TEST_TENANT_NAME | grep "$TEST_ROUTER " | awk '{print $2}')
function get_router_id() {

    # usage: get_router_id _router_id tenant_name router_name
    #        echo "result -> <$_router_id>"

    local _result_ptr=$1

    tenant_name=$2
    router_name=$3
    
    router_id=$(neutron router-list --tenant $tenant_name | grep "$router_name " | awk '{print $2}')
    printf "tenant_name[%s], router_name[%s] -> router_id[%s]\n" $tenant_name $router_name $router_id

    eval $_result_ptr=$router_id
}

# TEST_IMAGE_ID=$(nova image-list | grep "$TEST_IMAGE " | awk '{print $2}')
function get_image_id() {

    # usage: get_image_id _image_id image_name
    #        echo "result -> <$_image_id>"

    local _result_ptr=$1

    image_name=$2
    image_id=$(nova image-list | grep "$image_name " | awk '{print $2}')
    printf "image_name[%s] -> image_id[%s]\n" $image_name $image_id

    eval $_result_ptr=$image_id
}

# TEST_USER_ID=$(keystone user-list --tenant $TEST_TENANT_NAME | grep "$TEST_USER_NAME " | awk '{print $2}')
function get_user_id() {

    # usage: get_user_id _user_id tenant_name user_name
    #        echo "result -> <$_user_id>"

    local _result_ptr=$1

    tenant_name=$2
    user_name=$3
    
    user_id=$(keystone user-list --tenant $tenant_name | grep "$user_name " | awk '{print $2}')
    printf "tenant_name[%s], user_name[%s] -> user_id[%s]\n" $tenant_name $user_name $user_id

    eval $_result_ptr=$user_id
}

# TEST_ROLE_ID=$(keystone user-role-list --tenant $TEST_TENANT_NAME | grep "$TEST_ROLE_NAME " | awk '{print $2}')
function get_user_role_id() {

    # usage: get_user_role_id _user_role_id tenant_name user-role_name
    #        echo "result -> <$_user_role_id>"

    local _result_ptr=$1

    tenant_name=$2
    user_role_name=$3
    
    user_role_id=$(keystone user-role-list --tenant $tenant_name | grep "$user_role_name " | awk '{print $2}')
    printf "tenant_name[%s], user_role_name[%s] -> user_role_id[%s]\n" $tenant_name $user_role_name $user_role_id

    eval $_result_ptr=$user_role_id
}


# 
function get_vm_port_id()
{
    # usage: get_vm_port_id _result $vm $network $subnet
    #   get_vm_port_id _result hybrid_vm1_ubuntu-12.04 orange_vlan1_net orange_vlan1_subnet
    #   get_vm_port_id _result hybrid_vm2_ubuntu-12.04 orange_vlan2_net orange_vlan2_subnet
    #   get_vm_port_id _result ubuntu-12.04-test1 private_network private_subnetwork

    local _result_ptr=$1

    vm=$2
    network=$3
    subnet=$4

    get_vm_id _vm_id $vm

    query="
        select
        	np.id as port_id
        from
        	nova.instances as ni,
        	neutron.ports as np,
        	neutron.ipallocations as nia,
        	neutron.networks as nn,
        	neutron.subnets AS ns

        where
        	ni.deleted_at IS NULL
        	AND ni.uuid = '$_vm_id'
        	AND ni.uuid = np.device_id
        	AND np.id = nia.port_id
        	AND nn.name = '$network'
        	AND ns.name = '$subnet'
        	AND ns.id = nia.subnet_id"

    port_id=$(echo $query | mysql -N -uroot -pohhberry3333)
    echo "QUERY<<$query>>"
    echo "vm<$vm> -> port_id<$port_id>"
    eval $_result_ptr=$port_id
}

test() {

    get_tenant_id _tenant_id admin
    get_vm_id _vm_id hybrid_vm1_ubuntu-12.04
    get_net_id _net_id orange_vlan1_net
    get_subnet_id _subnet_id admin orange_vlan1_subnet 
    get_router_id _router_id admin my_router
    get_image_id _image_id ubuntu-12.04
    get_user_id _user_id admin admin
    get_user_role_id _user_role_id admin admin

    get_vm_port_id _port_id hybrid_vm1_ubuntu-12.04 orange_vlan1_net orange_vlan1_subnet    
}

# test