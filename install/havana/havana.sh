http://www.revolutionlabs.net/2013/11/part-1-how-to-install-openstack-havana.html


################################################################################
# allinone_havana: 10G NIC 2개 1G NIC 6개
#
#   eth0(1G)    -> mgmt
#   eth1(1G)    -> api internet
#   eth2(1G)    -> external
#   eth3(1G)    -> 
#   eth4(10G)   -> private
#   eth5(1G)    -> 
#   eth6(1G)    -> 
#   eth7(10G)   -> hybrid
################################################################################

export CONTROLLER_HOST=10.0.0.101
export CONTROLLER_PUBLIC_HOST=211.224.204.147
#
# controller node

CTRL_MGMT_IP=$CONTROLLER_HOST           # management network ip
CTRL_MGMT_SUBNET_MASK=255.255.255.0

CTRL_API_IP=$CONTROLLER_PUBLIC_HOST     # horizon api ip
CTRL_API_SUBNET_MASK=255.255.255.224
CTRL_API_GW=211.224.204.129
CTRL_API_DNS=8.8.8.8

CTRL_MGMT_NIC=eth0                  # management network nic info
CTRL_API_NIC=eth1                   # horizon api nic info

#
# network node

NTWK_MGMT_IP=$CTRL_MGMT_IP              # management network ip
NTWK_MGMT_SUBNET_MASK=255.255.255.0
    
NTWK_PUB_MGMT_IP=$CTRL_API_IP           # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함
NTWK_PUB_MGMT_SUBNET_MASK=$CTRL_API_SUBNET_MASK
NTWK_PUB_MGMT_GW=$CTRL_API_GW
NTWK_PUB_MGMT_DNS=$CTRL_API_DNS

NTWK_MGMT_NIC=$CTRL_MGMT_NIC        # management network nic info
NTWK_PRVT_NIC=eth1                  # private network trunk  -> trunk 이므로 설정 불필요
NTWK_EXT_NIC=eth2                   # external network trunk -> trunk 이므로 설정 불필요
NTWK_PUB_MGMT_NIC=$CTRL_API_NIC     # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함


#
# compute node 01
COM01_MGMT_IP=$CTRL_MGMT_NIC            # management network ip
COM01_MGMT_SUBNET_MASK=255.255.255.0
    
COM01_PUB_MGMT_IP=$CTRL_API_IP          # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함
COM01_PUB_MGMT_SUBNET_MASK=$CTRL_API_SUBNET_MASK
COM01_PUB_MGMT_GW=$CTRL_API_GW
COM01_PUB_MGMT_DNS=$CTRL_API_DNS

COM01_MGMT_NIC=$CTRL_MGMT_NIC       # management network ip
COM01_PRVT_NIC=eth4                 # 1G NIC private network trunk -> trunk 이므로 설정 불필요
COM01_HYBR_NIC=eth7                 # 1G NIC hybrid networkt trunk -> trunk 이므로 설정 불필요
COM01_PUB_MGMT_IP=$CTRL_API_NIC     # public management ip -> 초창기 패키지 설치시에 필요, 보안문제로 나중에는 빼야함

################################################################################




Part 1 - How to install OpenStack Havana on Ubuntu - Prerequisites, Horizon, Keystone, and Nova

Here's my test environment:
    - Ubuntu 12.04.3 LTS as the OS on all nodes
    - KVM as the hypervisor
    - MySQL hosts the databases
    - Neutron is used for networking
    - Keystone is used for authentication with MySQL as the backend
    - ML2 is the L2 agent
    - Open vSwitch is the L2 plugin
    - UTC is the configured time zone on all of the nodes

################################################################################
# Prerequisites
################################################################################

1.Install Ubuntu 12.04.2


2.Install Ubuntu OpenStack package pre-reqs and update Ubuntu

$ apt-get update 
$ apt-get -y install python-software-properties
$ add-apt-repository -y cloud-archive:havana

$ apt-get update
$ apt-get -y upgrade dist-upgrade
$ apt-get -y autoremove
$ reboot

3.Install the primary and supporting OpenStack Ubuntu packages

$ apt-get -y install mysql-server \
    python-mysqldb rabbitmq-server ntp keystone \
    python-keystone python-keystoneclient glance 
    nova-api nova-cert novnc nova-consoleauth nova-scheduler nova-novncproxy 
    nova-doc nova-conductor nova-ajax-console-proxy python-novaclient 
    cinder-api cinder-scheduler 
    openstack-dashboard memcached libapache2-mod-wsgi
    
################################################################################
# Configure the supporting services
################################################################################

1.Update the MySQL bind address    

$ my.cnf 변경
bind-address = 10.0.0.101
$ service mysql restart

2. Secure MySQL
$ mysql_secure_installation

3. Create the databases
$ mysql -u root -p

Cinder
mysql> CREATE DATABASE cinder;  
mysql> GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY 'password';  
mysql> GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY 'password';

Glance
mysql> CREATE DATABASE glance;  
mysql> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'password';  
mysql> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'password';

Keystone
mysql> CREATE DATABASE keystone;  
mysql> GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'password';  
mysql> GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'password';

Neutron
mysql> CREATE DATABASE neutron;  
mysql> GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'password';  
mysql> GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'password';

Nova
mysql> CREATE DATABASE nova;  
mysql> GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'password';  
mysql> GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'password';

Cleanup
mysql> FLUSH PRIVILEGES;
mysql> QUIT;

4. Create two OpenStack credential files
4.1 Create a random seed
$ openssl rand -hex 10
$ 4fcadbe846130de04cfc

4.2 Update the Keystone admin_token value
vi /etc/keystone/keystone.conf 
[DEFAULT]
admin_token = 4fcadbe846130de04cfc

4.3 Create the files

vi admin.token.creds
export OS_SERVICE_TOKEN=4fcadbe846130de04cfc
export OS_SERVICE_ENDPOINT=http://10.0.0.101:35357/v2.0

vi admin.user.creds
export OS_AUTH_URL=http://10.0.0.101:5000/v2.0
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=password

4.4 Add the authentication values to your profile
$ source admin.token.creds

여기서 Keystone 기능이 동작하는지 테스트 해보자