#!/bin/bash

# 오픈스택 변수정보 가져옴

source ./common_util.sh
source ./common_openstack_global_variable.sh

prepare() {

    # 오픈스텍 계정 생성 : openstack/ohhberry3333 <- ipmi로 원격 설치시 설정
    # root 패스워드 설정
    # § ubuntu@ubuntu:~$ sudo passwd root
    # § Enter New UNIX Password :  ohhberry3333  
    # § Reype New Nunix password : ohhberry3333

    # 먼저 설치를 위해서 원격 접속환경을 만든다.
    # LJG: 주의:: ubuntu desktop을 사용할 경우 아래 network-manager를 지워야 함.
    # apt-get purge network-manager

    # mv /etc/network/interfaces /etc/network/interfaces.old
    # cat > /etc/network/interfaces <<EOF
    # ------------------------------------------------------------------------------
    auto lo
    iface lo inet loopback
    
    auto eth1
    iface eth1 inet static
        address 211.224.204.157
        netmask 255.255.255.224
        gateway 211.224.204.129
        dns-nameservers 8.8.8.8
    # ------------------------------------------------------------------------------
    EOF
 
    # 우분투 Firewall 해제(이건 나중에 보안심의 이슈가 될 수 있슴)
    # $service networking restart
    # § sudo ufw disable
    # § apt-get update
    # § apt-get -y install python-software-properties
    # § add-apt-repositiory -y cloud-archive:havana
    # openssh 서버 설치
    # § sudo apt-get install -y openssh-server
    # - root 권한으로 외부에서 ssh 접속 허용 설정(우분투 12.04인 경우 불필요)
    #§ /etc/ssh/sshd_config 파일의 PermitRootLogin 설정값을  no -> yes로 변경한다.            

}

echo "
# ------------------------------------------------------------------------------
# ubuntu desktop을 사용할 경우 아래 network-manager를 지워야 함.
# ------------------------------------------------------------------------------"
apt-get purge network-manager

ask_continue_stop

echo "
# ------------------------------------------------------------------------------
# 우분투 레포지토리 설정 및 update !!!
# ------------------------------------------------------------------------------"

if [ $UBUNTU_VER = "12.04" ]
then
    echo "
    --------------------------------------------------------------------------------
    
    UBUNTU_VER = $UBUNTU_VER 
    apt-get install -y python-software-properties
    add-apt-repository cloud-$OPENSTACK_VER
    
    --------------------------------------------------------------------------------"
    
    sudo apt-get install -y python-software-properties    
    sudo add-apt-repository -y cloud-archive:$OPENSTACK_VER
else 
    echo "
    --------------------------------------------------------------------------------
    
    UBUNTU_VER = $UBUNTU_VER 
    apt-get install -y python-software-properties
    add-apt-repository cloud-$OPENSTACK_VER
    
    --------------------------------------------------------------------------------"
    sudo add-apt-repository -y cloud-archive:$OPENSTACK_VER        
fi

sudo apt-get update
sudo apt-get upgrade -y

echo "
# ------------------------------------------------------------------------------
# 우분투 시간대를 한국시간대에 맞추기 !!!
# ------------------------------------------------------------------------------    
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime    
--------------------------------------------------------------------------------"
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

echo "
# ------------------------------------------------------------------------------
# 추가할 cnode nic 정보 설정
# ------------------------------------------------------------------------------"

# compute node

COM_MGMT_IP=10.0.0.102            
COM_MGMT_SUBNET_MASK=255.255.255.0
   
# public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함    
COM_PUB_MGMT_IP=211.224.204.157     
COM_PUB_MGMT_SUBNET_MASK=255.255.255.224
COM_PUB_MGMT_GW=211.224.204.129
COM_PUB_MGMT_DNS=8.8.8.8
    
COM_MGMT_NIC=eth0                 # management network ip        
COM_PRVT_NIC=eth4                 # 10G NIC private network trunk -> trunk 이므로 설정 불필요
COM_HYBR_NIC=eth5                 # 10G NIC hybrid networkt trunk -> trunk 이므로 설정 불필요
COM_PUB_MGMT_NIC=eth1

    

echo "
--------------------------------------------------------------------------------
    오픈스택 컴퓨트 호스트 네트워크 정보
     네트워크 설정정보를 잘 확인하세요 
--------------------------------------------------------------------------------"
printf "%30s -> %s \n" COM_MGMT_IP $COM_MGMT_IP
printf "%30s -> %s \n" COM_MGMT_SUBNET_MASK $COM_MGMT_SUBNET_MASK
printf "%s\n" "----------------------------------"
printf "%30s -> %s \n" COM_PUB_MGMT_IP $COM_PUB_MGMT_IP
printf "%30s -> %s \n" COM_PUB_MGMT_SUBNET_MASK $COM_PUB_MGMT_SUBNET_MASK
printf "%30s -> %s \n" COM_PUB_MGMT_GW $COM_PUB_MGMT_GW
printf "%30s -> %s \n" COM_PUB_MGMT_DNS $COM_PUB_MGMT_DNS
printf "%s\n" "----------------------------------"
printf "%30s -> %s \n" COM_MGMT_NIC $COM_MGMT_NIC
printf "%30s -> %s \n" COM_PRVT_NIC $COM_PRVT_NIC
printf "%30s -> %s \n" COM_HYBR_NIC $COM_HYBR_NIC
printf "%30s -> %s \n" COM_PUB_MGMT_NIC $COM_PUB_MGMT_NIC
echo "--------------------------------------------------------------------------"


ask_continue_stop

echo "
# ------------------------------------------------------------------------------
# openstack environment resource(openstack_rc) 파일 생성 !!!
# ------------------------------------------------------------------------------"

rm -f ~/openstack_rc
cat > ~/openstack_rc <<EOF
# ------------------------------------------------------------------------------
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_AUTH_URL=http://${KEYSTONE_ENDPOINT}:5000/v2.0/
export OS_NO_CACHE=1
# ------------------------------------------------------------------------------
EOF

source ~/openstack_rc
cat ~/openstack_rc

echo "
# ------------------------------------------------------------------------------
# Zero Office 호스트 정보에 Cnode 추가
# ------------------------------------------------------------------------------"

mv /etc/hosts /etc/hosts.old
cat > /etc/hosts <<EOF
# ------------------------------------------------------------------------------
211.224.204.156 pub_controller
10.0.0.101 controller
10.0.0.102 cnode02
# ------------------------------------------------------------------------------
EOF

cat /etc/hosts


echo "
--------------------------------------------------------------------------------
/etc/network/interfaces 파일을 만들고
service network restart를 실행하면 제대로 동작하지 않는 경우가 많아
아래와 같이 개별적인 명령어로 처리
#---------------------------------------
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 10.0.0.102
    netmask 255.255.255.0

auto eth4
iface eth4 inet manual
    up ip link set dev $IFACE up
    down ip link set dev $IFACE down

auto eth5
iface eth5 inet manual
    up ip link set dev $IFACE up
    down ip link set dev $IFACE down

auto eth1
iface eth1 inet static
    address 211.224.204.146
    netmask 255.255.255.224
    gateway 211.224.204.129
    dns-nameservers 8.8.8.8
#---------------------------------------
    
# NIC 설정
ifconfig eth0 10.0.0.102 netmask 255.255.255.0 up
ifconfig eth1 211.224.204.157 netmask 255.255.255.224 up
ifconfig eth3 0.0.0.0 up
ifconfig eth5 0.0.0.0 up

# public nic에 default gw 설정
route add default gw 211.224.204.129 dev eth1

# dns 설정
nameserver 8.8.8.8 | tee -a /etc/resolv.conf
-------------------------------------------------------------------------------"

compute_network_setting() {

    ifconfig eth0 10.0.0.102 netmask 255.255.255.0 up
    ifconfig eth1 211.224.204.157 netmask 255.255.255.224 up
    ifconfig eth4 0.0.0.0 up
    ifconfig eth5 0.0.0.0 up

    route add default gw 211.224.204.129 dev eth1
    echo "nameserver 8.8.8.8" | tee -a /etc/resolv.conf
     
    echo '>>> check result'
    echo '# network interfaces  ------------------------------------------------'
    cat /etc/network/interfaces
    echo '# routing table ------------------------------------------------------'
    route -n
    echo '# dns ----------------------------------------------------------------'
    cat /etc/resolv.conf
    echo '# --------------------------------------------------------------------'
    
}
   

echo '
--------------------------------------------------------------------------------
    compute 서버에 커널 환경(네트워크 포워딩&필터) 수정
--------------------------------------------------------------------------------'
compute_syscontrol_change() {

    echo '
    # ------------------------------------------------------------------------------
    ### kernel setting change(ip_forward, rp_filter) to /etc/sysctl.conf!!!
    # ------------------------------------------------------------------------------'

    echo "
    net.ipv4.ip_forward=1
    net.ipv4.conf.all.rp_filter=0
    net.ipv4.conf.default.rp_filter=0" | tee -a /etc/sysctl.conf

    echo "  -> sudo sysctl -p"
    sudo sysctl -p

    echo '>>> check result
    # ------------------------------------------------------------------------------'
    cat /etc/sysctl.conf
    echo '
    # ------------------------------------------------------------------------------'

}

compute_syscontrol_change

echo '
--------------------------------------------------------------------------------
    compute 서버에 utility 설치
    
    apt-get install -y ntp dstat ethtool htop ngrep ifstat sysstat
--------------------------------------------------------------------------------'

apt-get install -y ntp dstat ethtool htop ngrep ifstat sysstat

echo '>>> check result ----------------------------------------------------'
dpkg -l | egrep "ntp|dstat|ethtool|htop|ngrep|ifstat|sysstat"
echo '# --------------------------------------------------------------------'
  
echo '
--------------------------------------------------------------------------------
    compute 서버에 KVM 설치 및 실행
--------------------------------------------------------------------------------'
source ./cnode_kvm_install.sh
    compute_kvm_install
    
echo '
--------------------------------------------------------------------------------
    compute 서버에 openvswitch 설치 및 실행
--------------------------------------------------------------------------------'
source ./cnode_ovs_install.sh
    compute_openvswitch_install
    compute_openvswitch_execute


echo '
--------------------------------------------------------------------------------
    compute 서버에 neutron 설치 및 구성
--------------------------------------------------------------------------------'
source ./cnode_neutron_install.sh
    compute_neutron_install
    compute_neutron_config
    compute_neutron_plugin_ovs_config
    compute_neutron_plugin_openvswitch_agent_restart


   
echo '
--------------------------------------------------------------------------------
    compute 서버에 nova 설치 및 구성
--------------------------------------------------------------------------------'
source ./cnode_nova_install.sh
    compute_nova_install        
    compute_nova_configure
    
    compute_nova_compute_configure
    compute_nova_restart

echo '
--------------------------------------------------------------------------------
    compute 서버를 가용성존(zero1)에 추가
--------------------------------------------------------------------------------'

# nova aggregate-create zero1 seocho.seoul.zo.kt
# nova aggregate-add-host zero1 cnode02
