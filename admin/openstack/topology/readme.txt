A. 시작하기 전에

1) list-vm.sh를 수정하여 nova database 접속 정보를 아래와 같이 설정해준다.  

NOVA_USER="nova"
NOVA_PASS="nova"
NOVA_DB="nova"

2) get_vlan_tag.py를 열어 ovs database 접속 정보를 아래와 같이 설정해준다.
 
OVSDB_IP = '211.224.204.156'
OVSDB_PORT = 6632

***  만약 ovs database에 tcp 접속 설정을 하지 않았다면 
이를 /admin/openstack/ovsdb에서 설정해준다.

B. 토폴로지 정보 확인

~#> ./list-vm.sh 