0928-23시 시작

기본: 설치가 끝난 후에라도 모든 conf 파일에 상세로그 설정
verbose=True
debug=True

syslog 설정
use_syslog = True
syslog_log_facility = LOG_LOCAL0

################################################################################
#
###     1. Basic OS Configuration
#
################################################################################

# ------------------------------------------------------------------------------
1-1. Networking
# ------------------------------------------------------------------------------

## 1. /etc/networking/interfaces 작성

# ------------------------------------------------------------------------------
# The loopback network interface
auto lo
iface lo inet loopback

# management network
auto eth0
    iface eth0 inet static
    address 10.0.0.101
    netmask 255.255.255.0

# api network
auto eth1
iface eth1 inet static
    address 211.224.204.156
    netmask 255.255.255.224
    gateway 211.224.204.129
    # dns-* options are implemented by the resolvconf package, if installed
    dns-nameservers 8.8.8.8

# external network
auto eth2
iface eth2 inet manual
    up ip link set dev $IFACE up
    down ip link set dev $IFACE down

# private network
auto eth4
iface eth4 inet manual
    up ip link set dev $IFACE up
    down ip link set dev $IFACE down

# hybrid network
auto eth5
iface eth5 inet manual
    up ip link set dev $IFACE up
    down ip link set dev $IFACE down

## 2. 네트워킹 재시작
$ service networking restart

## 3. /etc/hostname 편집
controller

## 4. hostname 수정명령
$ hostname controller

## 5. /etc/hosts 편집
211.224.204.156 pub_controller
10.0.0.101 controller  controller.east.dj_lab.zo.kt
10.0.0.102 cnode02   cnode02.east.dj_lab.zo.kt

# ------------------------------------------------------------------------------
1-2. NTP 설치
# ------------------------------------------------------------------------------
apt-get install ntp

# ------------------------------------------------------------------------------
1-3. Passwords
# ------------------------------------------------------------------------------

ADMIN_PASS=ohhberry3333
DB_PASS=ohhberry3333
RABBIT_PASS=rabbit
KEYSTONE_DBPASS=keystone
GLANCE_DBPASS=glance
GLANCE_PASS=glance
NOVA_DBPASS=nova
NOVA_PASS=nova
DASH_DBPASS=dash
CINDER_DBPASS=cinder
CINDER_PASS=cinder
NEUTRON_DBPASS=neutron
NEUTRON_PASS=neutron
HEAT_DBPASS=heat
HEAT_PASS=heat
CEILOMETER_DBPASS=ceilometer
CEILOMETER_PASS=ceilometer

# ------------------------------------------------------------------------------
1-4. MySQL
# ------------------------------------------------------------------------------
controller node 작업

## 1. 설치
$ apt-get -y nstall python-mysqldb mysql-server

## 2. /etc/mysql/my.cnf 편집
[mysqld]
...
bind-address = 0.0.0.0
max_connections = 512

## 3. /etc/mysql/conf.d/skip-name-resolve.cnf 편집(옵션)
# ip로 db접속하도록 설정(name resolve 사용안함)'
[mysqld]
skip-name-resolve

## 4. /etc/mysql/conf.d/01-utf8.cnf 편집(옵션)
# encoding 설정(utf8)'
[mysqld]
collation-server = utf8_general_ci
init-connect='SET NAMES utf8'
character-set-server = utf8

## 5. mysql 권한과 접속환경 설정(외부에서도 root로 접속가능하게)'
mysql -u root -p${DB_PASS} -h localhost -e "GRANT ALL ON *.* to root@\"localhost\" IDENTIFIED BY \"${DB_PASS}\" WITH GRANT OPTION;"
mysql -u root -p${DB_PASS} -h localhost -e "GRANT ALL ON *.* to root@\"${MYSQL_HOST}\" IDENTIFIED BY \"${DB_PASS}\" WITH GRANT OPTION;"
mysql -u root -p${DB_PASS} -h localhost -e "GRANT ALL ON *.* to root@\"%\" IDENTIFIED BY \"${DB_PASS}\" WITH GRANT OPTION;"
mysqladmin -uroot -p${DB_PASS} flush-privileges

$ mysql -u root -pohhberry3333 -h localhost -e "GRANT ALL ON *.* to root@\"localhost\" IDENTIFIED BY \"ohhberry3333\" WITH GRANT OPTION;"
$ mysql -u root -pohhberry3333 -h localhost -e "GRANT ALL ON *.* to root@\"controller\" IDENTIFIED BY \"ohhberry3333\" WITH GRANT OPTION;"
$ mysql -u root -pohhberry3333 -h localhost -e "GRANT ALL ON *.* to root@\"%\" IDENTIFIED BY \"ohhberry3333\" WITH GRANT OPTION;"
$ mysqladmin -uroot -pohhberry3333 flush-privileges

## 5. mysql 재시작
service mysql restart

# ------------------------------------------------------------------------------
1-5. Openstack Packages
# ------------------------------------------------------------------------------

## 1. Install the Ubuntu Cloud Archive for Havana:
$ apt-get install python-software-properties
$ add-apt-repository cloud-archive:havana

## 2. Update the package database, upgrade your system, and reboot for all changes to take effect:
$ apt-get update && apt-get dist-upgrade
$ reboot

# ------------------------------------------------------------------------------
1-6. Messaging Server
# ------------------------------------------------------------------------------

## 1. apt-get -y install rabbitmq-server
## 2. rabbitmqctl change_password guest 바꿀패스워드
$ rabbitmqctl change_password guest rabbit

################################################################################
#
###     2. Keystone
#
################################################################################

# ------------------------------------------------------------------------------
2-1. Install Keystone
# ------------------------------------------------------------------------------

## 1. apt-get install keystone

## 2. /etc/keystone/keystone.conf 편집
[sql]
# The SQLAlchemy connection string used to connect to the database
# connection = mysql://keystone:KEYSTONE_DBPASS@controller/keystone
connection = mysql://keystone:keystone@controller/keystone

## 3. rm /var/lib/keystone/keystone.db

## 4. create keystone database
mysql -uroot -p$MYSQL_ROOT_PASS -e "CREATE DATABASE keystone;"
mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$MYSQL_KEYSTONE_PASS';"
mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$MYSQL_KEYSTONE_PASS';"

mysql -uroot -pohhberry3333 -e "CREATE DATABASE keystone;"
mysql -uroot -pohhberry3333 -e "GRANT ALL ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'keystone';"
mysql -uroot -pohhberry3333 -e "GRANT ALL ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'keystone';"

## 5. keystone-manage db_sync

## 6. admin_token 생성
$ openssl rand -hex 10
2fbaa23706722ca64e7e

## 7. /etc/keystone/keystone.conf 편집
[DEFAULT]
# A "shared secret" between keystone and other openstack services
admin_token = 2fbaa23706722ca64e7e
...

## 8. service keystone restart

# ------------------------------------------------------------------------------
2-2. Define users, tenants, and roles
# ------------------------------------------------------------------------------

## 1. 사용자 계정/암호를 설정하기 전에 keystone을 token으로 인증하여 사용하기 위해 환경설정
# LJG: notice
# 사용자계정을 만들고 실제 사용시에는 환경변수 2개를 unset해야 함.
$ export OS_SERVICE_TOKEN=2fbaa23706722ca64e7e
$ export OS_SERVICE_ENDPOINT=http://controller:35357/v2.0

## 2. create a tenant for an administrative user and a tenant for other OpenStack services to use
$ keystone tenant-create --name=admin --description="Admin Tenant"
$ keystone tenant-create --name=service --description="Service Tenant"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |           Admin Tenant           |
|   enabled   |               True               |
|      id     | 384bc9fa63624974a2bbf896be6fb9ce |
|     name    |              admin               |
+-------------+----------------------------------+
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |          Service Tenant          |
|   enabled   |               True               |
|      id     | 33e2989d341e4a72ada13e9649a45d7f |
|     name    |             service              |
+-------------+----------------------------------+
## 3. admin으로 관리자 계정 생성
keystone user-create --name=admin --pass=ohhberry3333 --email=admin@kt.com
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|  email   |           admin@kt.com           |
| enabled  |               True               |
|    id    | e3d28992d84045de9fa631d583f2c799 |
|   name   |              admin               |
+----------+----------------------------------+

## 4. admin role 생성
# LJG: notice
# Create a role for administrative tasks called admin.
# Any roles you create should map to roles specified in the policy.json files
# of the various OpenStack services.
# The default policy files use the admin role to allow access to most services
keystone role-create --name=admin
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|    id    | 7a48dae7d1ca4f0387199a19690d3342 |
|   name   |              admin               |
+----------+----------------------------------+
## 5. admin role 생성
# you have to add roles to users. Users always log in with a tenant,
# and roles are assigned to users within tenants.
# Add the admin role to the admin user when logging in with the admin tenant.
keystone user-role-add --user=admin --tenant=admin --role=admin

# ------------------------------------------------------------------------------
2-3. Define services and API endpoints
# ------------------------------------------------------------------------------

keystone service-create:  Describes the service.
keystone endpoint-create: Associates API endpoints with the service

## 1. keystone 서비스 생성
$ keystone service-create --name=keystone --type=identity --description="Keystone Identity Service"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |    Keystone Identity Service     |
|      id     | 32e8e8f8e2294e09a975b0c6953617bf |
|     name    |             keystone             |
|     type    |             identity             |
+-------------+----------------------------------+
## 2. keystone endpoint 생성: keystone 서비스와 연결
$ keystone endpoint-create \
  --service-id=32e8e8f8e2294e09a975b0c6953617bf \
  --publicurl=http://pub_controller:5000/v2.0 \
  --internalurl=http://controller:5000/v2.0 \
  --adminurl=http://controller:35357/v2.0
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
|   adminurl  |   http://controller:35357/v2.0   |
|      id     | 2c76e879a2614c5d9e9be9267df74560 |
| internalurl |   http://controller:5000/v2.0    |
|  publicurl  |   http://controller:5000/v2.0    |
|    region   |            regionOne             |
|  service_id | 32e8e8f8e2294e09a975b0c6953617bf |
+-------------+----------------------------------+

# ------------------------------------------------------------------------------
2-4. 검증
# ------------------------------------------------------------------------------

## 1. (LJG: notice) 사용자계정/암호를 만들었으니 이젠 임시 인증용 환경변수 unset
$ unset OS_SERVICE_TOKEN OS_SERVICE_ENDPOINT

## 2. keystone 검증(아직 환경변수를 사용하지 않는 환경)
keystone --os-username=admin --os-password=ohhberry3333 \
  --os-auth-url=http://controller:35357/v2.0 token-get
+----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Property |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        Value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
+----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| expires  |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 2014-09-28T15:38:33Z                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
|    id    | MIIC8QYJKoZIhvcNAQcCoIIC4jCCAt4CAQExCTAHBgUrDgMCGjCCAUcGCSqGSIb3DQEHAaCCATgEggE0eyJhY2Nlc3MiOiB7InRva2VuIjogeyJpc3N1ZWRfYXQiOiAiMjAxNC0wOS0yN1QxNTozODozMy4yODE4NzQiLCAiZXhwaXJlcyI6ICIyMDE0LTA5LTI4VDE1OjM4OjMzWiIsICJpZCI6ICJwbGFjZWhvbGRlciJ9LCAic2VydmljZUNhdGFsb2ciOiBbXSwgInVzZXIiOiB7InVzZXJuYW1lIjogImFkbWluIiwgInJvbGVzX2xpbmtzIjogW10sICJpZCI6ICJlM2QyODk5MmQ4NDA0NWRlOWZhNjMxZDU4M2YyYzc5OSIsICJyb2xlcyI6IFtdLCAibmFtZSI6ICJhZG1pbiJ9LCAibWV0YWRhdGEiOiB7ImlzX2FkbWluIjogMCwgInJvbGVzIjogW119fX0xggGBMIIBfQIBATBcMFcxCzAJBgNVBAYTAlVTMQ4wDAYDVQQIDAVVbnNldDEOMAwGA1UEBwwFVW5zZXQxDjAMBgNVBAoMBVVuc2V0MRgwFgYDVQQDDA93d3cuZXhhbXBsZS5jb20CAQEwBwYFKw4DAhowDQYJKoZIhvcNAQEBBQAEggEApCXVU0zh67LQ2Ga2QMcMyujm4WTYz4slYAuZ-bToNAj5UdxA-Wn7RRmFsCBLHx6U0vNhPSI+ZVaH7Fl9EDZW3h2eYKFPxfSrVZ9plXAQRrrp-8iJVeqVa9+d4PNgN691d259dluS70DkonzUe8+fi96-6NY0XtBOdHfttlraVKytnQlE6x5jLhIGT0N2RzafvWzGQJ+mEdiCKatQKaWmiZXkzUEBPEKQS8mbWlxoy5lQ4t9wUBJJ4-hwXDuk4LyOUqYdhlasb+0H7zlrGztnwKvaRgD85x7Ra0aS7kt9cfrmgkQOAG4XUov2wEvJ-zaaoBTUSOi3lMNnfw7xWlhx0g== |
| user_id  |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           e3d28992d84045de9fa631d583f2c799                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
+----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
## 3. 검증2
keystone --os-username=admin --os-password=ohhberry3333 --os-tenant-name=admin \
  --os-auth-url=http://controller:35357/v2.0 token-get
+-----------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
|  Property |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  Value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
+-----------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
|  expires  |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           2014-09-28T15:38:56Z                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
|     id    | MIIEsgYJKoZIhvcNAQcCoIIEozCCBJ8CAQExCTAHBgUrDgMCGjCCAwgGCSqGSIb3DQEHAaCCAvkEggL1eyJhY2Nlc3MiOiB7InRva2VuIjogeyJpc3N1ZWRfYXQiOiAiMjAxNC0wOS0yN1QxNTozODo1Ni4zMjQ0NDgiLCAiZXhwaXJlcyI6ICIyMDE0LTA5LTI4VDE1OjM4OjU2WiIsICJpZCI6ICJwbGFjZWhvbGRlciIsICJ0ZW5hbnQiOiB7ImRlc2NyaXB0aW9uIjogIkFkbWluIFRlbmFudCIsICJlbmFibGVkIjogdHJ1ZSwgImlkIjogIjM4NGJjOWZhNjM2MjQ5NzRhMmJiZjg5NmJlNmZiOWNlIiwgIm5hbWUiOiAiYWRtaW4ifX0sICJzZXJ2aWNlQ2F0YWxvZyI6IFt7ImVuZHBvaW50cyI6IFt7ImFkbWluVVJMIjogImh0dHA6Ly9jb250cm9sbGVyOjM1MzU3L3YyLjAiLCAicmVnaW9uIjogInJlZ2lvbk9uZSIsICJpbnRlcm5hbFVSTCI6ICJodHRwOi8vY29udHJvbGxlcjo1MDAwL3YyLjAiLCAiaWQiOiAiM2RlNmEyNzY1Y2Q5NDJlMzhjOWE5OTkxYTNhYzQ0MGEiLCAicHVibGljVVJMIjogImh0dHA6Ly9jb250cm9sbGVyOjUwMDAvdjIuMCJ9XSwgImVuZHBvaW50c19saW5rcyI6IFtdLCAidHlwZSI6ICJpZGVudGl0eSIsICJuYW1lIjogImtleXN0b25lIn1dLCAidXNlciI6IHsidXNlcm5hbWUiOiAiYWRtaW4iLCAicm9sZXNfbGlua3MiOiBbXSwgImlkIjogImUzZDI4OTkyZDg0MDQ1ZGU5ZmE2MzFkNTgzZjJjNzk5IiwgInJvbGVzIjogW3sibmFtZSI6ICJhZG1pbiJ9XSwgIm5hbWUiOiAiYWRtaW4ifSwgIm1ldGFkYXRhIjogeyJpc19hZG1pbiI6IDAsICJyb2xlcyI6IFsiN2E0OGRhZTdkMWNhNGYwMzg3MTk5YTE5NjkwZDMzNDIiXX19fTGCAYEwggF9AgEBMFwwVzELMAkGA1UEBhMCVVMxDjAMBgNVBAgMBVVuc2V0MQ4wDAYDVQQHDAVVbnNldDEOMAwGA1UECgwFVW5zZXQxGDAWBgNVBAMMD3d3dy5leGFtcGxlLmNvbQIBATAHBgUrDgMCGjANBgkqhkiG9w0BAQEFAASCAQA9jH9MZJ7ukTeViBRPXa7hSdc+9r5DK00r-t2E7aJi8ux5W9vkXnVtPG+r24th9hOHqsjgM57ormv7rwwfkFM8CAK81JaY5M6uDYkOsTIdrPTK6zBgG7X78vQAYPssHV-6F7UlsEfqz4fGdnwTvrtzcmbEgHSLBR+ZCd-OsRs2JmgS12w53S6F-mhieSAT8uMxNSJsbk2gAKpqWpdNmva-ebSfvB8O1DZ7dfc5ePN8tw-soWr+tz6yowLXiZSafNd5MDSikVsFRPooo1AEfNE3uqj55BCSMlf+1lKeF-nhfgUWt4NPhLCeVfYwtq+YSyd23lbykKTv53OYPhDvDO8A |
| tenant_id |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     384bc9fa63624974a2bbf896be6fb9ce                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
|  user_id  |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     e3d28992d84045de9fa631d583f2c799                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
+-----------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

## 4. 인증경변수 파일 생성(~/openstack_rc) :
#     (LJG: notice)openstack cli사용전에 반드시 source 해야함
export OS_USERNAME=admin
export OS_PASSWORD=ohhberry3333
export OS_TENANT_NAME=admin
export OS_AUTH_URL=http://controller:35357/v2.0

## 5. source ~/openstack_rc

## 6. 환경변수 적용디 잘되나 검증
keystone user-list
+----------------------------------+-------+---------+--------------+
|                id                |  name | enabled |    email     |
+----------------------------------+-------+---------+--------------+
| e3d28992d84045de9fa631d583f2c799 | admin |   True  | admin@kt.com |
+----------------------------------+-------+---------+--------------+







################################################################################
#
###     3. Glance
#
################################################################################

# ------------------------------------------------------------------------------
3-1. 설치
# ------------------------------------------------------------------------------

## 1. apt-get -y install glance python-glanceclient

## 2. 데이터베이스 접속환경 편집
   /etc/glance/glance-api.conf
   /etc/glance/glance-registry.conf

[DEFAULT]
...
# SQLAlchemy connection string for the reference implementation
# registry server. Any valid SQLAlchemy connection string is fine.
# See: http://www.sqlalchemy.org/docs/05/reference/sqlalchemy/connections.html#sqlalchemy.create_engine
#sql_connection = mysql://glance:GLANCE_DBPASS@controller/glance
sql_connection = mysql://glance:glance@controller/glance

## 3. rm /var/lib/glance/glance.sqlite

## 4. glance 데이터베이스 생성

$ mysql -uroot -pohhberry3333 -e "CREATE DATABASE glance;"
$ mysql -uroot -pohhberry3333 -e "GRANT ALL ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'glance';"
$ mysql -uroot -pohhberry3333 -e "GRANT ALL ON glance.* TO 'glance'@'%' IDENTIFIED BY 'glance';"

## 5. glance 스키마 생성
$ glance-manage db_sync

## 6. glance user 생성 및 role 추가
# Create a glance user that the Image Service can use to authenticate with the Identity Service.
# Choose a password and specify an email address for the glance user.
# Use the service tenant and give the user the admin role.

$ keystone user-create --name=glance --pass=glance --email=glance@kt.com
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|  email   |          glance@kt.com           |
| enabled  |               True               |
|    id    | 3be2e3a4708a4337ac10f97c94c17ea6 |
|   name   |              glance              |
+----------+----------------------------------+
$ keystone user-role-add --user=glance --tenant=service --role=admin

## 7. conf 파일에 인증을 사용할 수 있도록 keystone 정보 추가
   /etc/glance/glance-api.conf
   /etc/glance/glance-registry.conf

- 아래정보 각 섹션에 추가
[keystone_authtoken]
...
auth_uri = http://controller:5000
auth_host = controller
auth_port = 35357
auth_protocol = http
admin_tenant_name = service
admin_user = glance
admin_password = glance

[paste_deploy]
...
flavor = keystone

## 8. ini 파일에 인증을 사용할 수 있도록 keystone 정보 추가
   /etc/glance/glance-api-paste.ini
   /etc/glance/glance-registry-paste.ini

[filter:authtoken]
paste.filter_factory=keystoneclient.middleware.auth_token:filter_factory
auth_host=controller
admin_user=glance
admin_tenant_name=service
admin_password=glance

## 9. glance 서비스 생성
$ keystone service-create --name=glance --type=image --description="Glance Image Service"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |       Glance Image Service       |
|      id     | 746401f20fb34b4889a4788dc5f2b9c9 |
|     name    |              glance              |
|     type    |              image               |
+-------------+----------------------------------+
## 10. glance 서비스 endpoint 생성
$ keystone endpoint-create \
  --service-id=746401f20fb34b4889a4788dc5f2b9c9 \
  --publicurl=http://pub_controller:9292 \
  --internalurl=http://controller:9292 \
  --adminurl=http://controller:9292
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
|   adminurl  |      http://controller:9292      |
|      id     | 268bde72e8a74e39b4388ec6f613e791 |
| internalurl |      http://controller:9292      |
|  publicurl  |      http://controller:9292      |
|    region   |            regionOne             |
|  service_id | 746401f20fb34b4889a4788dc5f2b9c9 |
+-------------+----------------------------------+

## 11. glance 서비스 재시작
$ service glance-registry restart
$ service glance-api restart


# ------------------------------------------------------------------------------
3-2. 검증
# ------------------------------------------------------------------------------

## 1. download cirros image
$ mkdir images
$ cd images/
$ wget http://cdn.download.cirros-cloud.net/0.3.1/cirros-0.3.1-x86_64-disk.img

## 2. upload image

# glance image-create --name=imageLabel --disk-format=fileFormat --container-format=containerFormat --is-public=accessValue < imageFile
$ glance image-create --name="cirros" --disk-format=qcow2 \
  --container-format=bare --is-public=true < cirros-0.3.1-x86_64-disk.img
+------------------+--------------------------------------+
| Property         | Value                                |
+------------------+--------------------------------------+
| checksum         | d972013792949d0d3ba628fbe8685bce     |
| container_format | bare                                 |
| created_at       | 2014-09-27T16:37:06                  |
| deleted          | False                                |
| deleted_at       | None                                 |
| disk_format      | qcow2                                |
| id               | e4d8bb62-288a-46fe-a7a3-16bc881d5eab |
| is_public        | True                                 |
| min_disk         | 0                                    |
| min_ram          | 0                                    |
| name             | cirros                               |
| owner            | 384bc9fa63624974a2bbf896be6fb9ce     |
| protected        | False                                |
| size             | 13147648                             |
| status           | active                               |
| updated_at       | 2014-09-27T16:37:06                  |
+------------------+--------------------------------------+
## 3. image list
$ glance image-list
+--------------------------------------+--------+-------------+------------------+----------+--------+
| ID                                   | Name   | Disk Format | Container Format | Size     | Status |
+--------------------------------------+--------+-------------+------------------+----------+--------+
| e4d8bb62-288a-46fe-a7a3-16bc881d5eab | cirros | qcow2       | bare             | 13147648 | active |
+--------------------------------------+--------+-------------+------------------+----------+--------+












################################################################################
#
###     4. Cinder
#
################################################################################

# ------------------------------------------------------------------------------
4-1. 설치(controller node)
# ------------------------------------------------------------------------------

## 1.
    apt-get install cinder-api cinder-scheduler cinder-volume
    apt-get install lvm2

## 2. 데이터베이스 접속환경 편집
   /etc/cinder/cinder.conf

[database]
...
#connection = mysql://cinder:CINDER_DBPASS@controller/cinder
connection = mysql://cinder:cinder@controller/cinder

## 3. rm -f /var/lib/cinder/cinder.sqlite

## 4. cinder 데이터베이스 생성

$ mysql -uroot -pohhberry3333 -e "CREATE DATABASE cinder;"
$ mysql -uroot -pohhberry3333 -e "GRANT ALL ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY 'cinder';"
$ mysql -uroot -pohhberry3333 -e "GRANT ALL ON cinder.* TO 'cinder'@'%' IDENTIFIED BY 'cinder';"

## 5. cinder 스키마 생성
$ cinder-manage db sync

## 6. cinder user 생성 및 role 추가
$ keystone user-create --name=cinder --pass=cinder --email=cinder@kt.com
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|  email   |          cinder@kt.com           |
| enabled  |               True               |
|    id    | e9221bdf19ef4e28b488c99c443172ed |
|   name   |              cinder              |
+----------+----------------------------------+

$ keystone user-role-add --user=cinder --tenant=service --role=admin

## 7. ini 파일에 인증을 사용할 수 있도록 keystone 정보 추가
   /etc/cinder/api-paste.ini

[filter:authtoken]
paste.filter_factory=keystoneclient.middleware.auth_token:filter_factory
auth_host=controller
auth_port = 35357
auth_protocol = http
auth_uri = http://controller:5000
admin_tenant_name=service
admin_user=cinder
admin_password=cinder

## 8. conf 파일에 rabbitmq 정보 추가
   /etc/cinder/cinder.conf

[DEFAULT]
...
rpc_backend = cinder.openstack.common.rpc.impl_kombu
rabbit_host = controller
rabbit_port = 5672
rabbit_userid = guest
rabbit_password = rabbit


## 9. cinder 서비스 생성
$ keystone service-create --name=cinder --type=volume \
  --description="Cinder Volume Service"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |      Cinder Volume Service       |
|      id     | 058a36b51d3e41a38d11801fb6defd7f |
|     name    |              cinder              |
|     type    |              volume              |
+-------------+----------------------------------+

$ keystone service-create --name=cinderv2 --type=volumev2 \
  --description="Cinder Volume Service V2"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |     Cinder Volume Service V2     |
|      id     | 20f21f7e871644cfb1550fb150934bd4 |
|     name    |             cinderv2             |
|     type    |             volumev2             |
+-------------+----------------------------------+

## 10. cinder 서비스 endpoint 생성
$ keystone endpoint-create \
  --service-id=058a36b51d3e41a38d11801fb6defd7f \
  --publicurl=http://pub_controller:8776/v1/%\(tenant_id\)s \
  --internalurl=http://controller:8776/v1/%\(tenant_id\)s \
  --adminurl=http://controller:8776/v1/%\(tenant_id\)s
+-------------+-----------------------------------------+
|   Property  |                  Value                  |
+-------------+-----------------------------------------+
|   adminurl  | http://controller:8776/v1/%(tenant_id)s |
|      id     |     8079954993184fb4bbe6d9e867c2f7da    |
| internalurl | http://controller:8776/v1/%(tenant_id)s |
|  publicurl  | http://controller:8776/v1/%(tenant_id)s |
|    region   |                regionOne                |
|  service_id |     058a36b51d3e41a38d11801fb6defd7f    |
+-------------+-----------------------------------------+

$ keystone endpoint-create \
  --service-id=20f21f7e871644cfb1550fb150934bd4 \
  --publicurl=http://pub_controller:8776/v2/%\(tenant_id\)s \
  --internalurl=http://controller:8776/v2/%\(tenant_id\)s \
  --adminurl=http://controller:8776/v2/%\(tenant_id\)s
+-------------+-----------------------------------------+
|   Property  |                  Value                  |
+-------------+-----------------------------------------+
|   adminurl  | http://controller:8776/v2/%(tenant_id)s |
|      id     |     426c2edb5a6d44cc9bd2f9b4683e8236    |
| internalurl | http://controller:8776/v2/%(tenant_id)s |
|  publicurl  | http://controller:8776/v2/%(tenant_id)s |
|    region   |                regionOne                |
|  service_id |     20f21f7e871644cfb1550fb150934bd4    |
+-------------+-----------------------------------------+

## 11. cinder 서비스 재시작
$ service cinder-scheduler restart
$ service cinder-api restart
$ service cinder-volume restart

## 12. 일단 api만 검증
$ cinder service-list
+------------------+------------+------+---------+-------+------------+
|      Binary      |    Host    | Zone |  Status | State | Updated_at |
+------------------+------------+------+---------+-------+------------+
| cinder-scheduler | controller | nova | enabled |  down |    None    |
|  cinder-volume   | controller | nova | enabled |  down |    None    |
+------------------+------------+------+---------+-------+------------+

###################################################################
# LJG: block node를 따로 구성할 때는 아래 사항을 심도있게 설정해야 함.
#
# 1 $ apt-get install lvm2
# 2 $ pvcreate /dev/sdb
# 3 $ vgcreate cinder-volumes /dev/sdb
# 4 /etc/lvm/lvm.conf 편집
devices {
...
filter = [ "a/sda1/", "a/sdb/", "r/.*/"]
...
}
# 5 $ apt-get install cinder-volume
# 6 ini 파일에 인증을 사용할 수 있도록 keystone 정보 추가
# 7 conf 파일에 rabbitmq 정보 추가
# 8 conf 파일에 database section 정보 추가
# 9 $ service tgt restart

요기까지 오는데 3시간 30분 걸림. ㅜㅜㅜㅜ 역시 노가다....




################################################################################
#
###     5. Nova
#       :: compute node를 따로가져갈 때는 controller node와 compute node 각각 설치 
#       :: controller에 모두 설치할때는 개별적으로 설치된 것에서 중복설정(치)를 빼고 
#          하나로 합치면 됨
################################################################################

# ------------------------------------------------------------------------------
5-1. 설치(controller node) cnode 따로 구성한다고 가정
# ------------------------------------------------------------------------------

## 1. apt-get -y install nova-novncproxy novnc nova-api \
            nova-ajax-console-proxy nova-cert nova-conductor \
            nova-consoleauth nova-doc nova-scheduler \
            python-novaclient

## 2. rm /var/lib/nova/nova.sqlite

## 3. 데이터베이스 접속환경 편집
   /etc/nova/nova.conf

...
[database]
# The SQLAlchemy connection string used to connect to the database
connection = mysql://nova:nova@controller/nova

[keystone_authtoken]
auth_host = controller
auth_port = 35357
auth_protocol = http
admin_tenant_name = service
admin_user = nova
admin_password = nova

## 4. conf 파일에 rabbitmq 정보 추가
   /etc/nova/nova.conf

[DEFAULT]
rpc_backend = nova.rpc.impl_kombu
rabbit_host = controller
rabbit_password = rabbit

## 5. nova 데이터베이스 생성

$ mysql -uroot -pohhberry3333 -e "CREATE DATABASE nova;"
$ mysql -uroot -pohhberry3333 -e "GRANT ALL ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'nova';"
$ mysql -uroot -pohhberry3333 -e "GRANT ALL ON nova.* TO 'nova'@'%' IDENTIFIED BY 'nova';"

## 6. nova 스키마 생성
$ nova-manage db sync

## 7. conf 파일에 vnc 접속환경 정보 추가
   /etc/nova/nova.conf

...
[DEFAULT]
...
# vnc setting
novnc_enabled=true
novncproxy_base_url=http://211.224.204.156:6080/vnc_auto.html
novncproxy_port=6080
vncserver_proxyclient_address=10.0.0.101
vncserver_listen=0.0.0.0

## 8. nova user 생성 및 role 추가

$ keystone user-create --name=nova --pass=nova --email=nova@kt.com
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|  email   |           nova@kt.com            |
| enabled  |               True               |
|    id    | 5edcc1735b704f3da36f7b5188197ed7 |
|   name   |               nova               |
+----------+----------------------------------+

$ keystone user-role-add --user=nova --tenant=service --role=admin

## 9. conf 파일에 인증을 사용할 수 있도록 keystone 정보 추가
   /etc/nova/nova.conf

[DEFAULT]
...
auth_strategy=keystone

## 10. ini 파일에 인증을 사용할 수 있도록 keystone 정보 추가
   /etc/nova/api-paste.ini
   
[filter:authtoken]
paste.filter_factory = keystoneclient.middleware.auth_token:filter_factory
auth_host = controller
auth_port = 35357
auth_protocol = http
auth_uri = http://controller:5000/v2.0
admin_tenant_name = service
admin_user = nova
admin_password = nova

## 11. nova 서비스 생성
$ keystone service-create --name=nova --type=compute --description="Nova Compute service"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |       Nova Compute service       |
|      id     | 003bc153da524b3bb0ea5902498c07bc |
|     name    |               nova               |
|     type    |             compute              |
+-------------+----------------------------------+

## 12. nova 서비스 endpoint 생성
$ keystone endpoint-create \
  --service-id=003bc153da524b3bb0ea5902498c07bc \
  --publicurl=http://pub_controller:8774/v2/%\(tenant_id\)s \
  --internalurl=http://controller:8774/v2/%\(tenant_id\)s \
  --adminurl=http://controller:8774/v2/%\(tenant_id\)s
+-------------+-----------------------------------------+
|   Property  |                  Value                  |
+-------------+-----------------------------------------+
|   adminurl  | http://controller:8774/v2/%(tenant_id)s |
|      id     |     273da7b43d0a4c8aa7b9269cbb6c43a9    |
| internalurl | http://controller:8774/v2/%(tenant_id)s |
|  publicurl  | http://controller:8774/v2/%(tenant_id)s |
|    region   |                regionOne                |
|  service_id |     003bc153da524b3bb0ea5902498c07bc    |
+-------------+-----------------------------------------+

## 13. nova 서비스 재시작
$ service nova-api restart
$ service nova-cert restart
$ service nova-consoleauth restart
$ service nova-scheduler restart
$ service nova-conductor restart
$ service nova-novncproxy restart

## 14. 검증
$ nova image-list
+--------------------------------------+--------+--------+--------+
| ID                                   | Name   | Status | Server |
+--------------------------------------+--------+--------+--------+
| e4d8bb62-288a-46fe-a7a3-16bc881d5eab | cirros | ACTIVE |        |
+--------------------------------------+--------+--------+--------+

# ------------------------------------------------------------------------------
5-2. 설치(compute node) cnode 따로 구성한다고 가정
# ------------------------------------------------------------------------------

## 1. apt-get -y install nova-compute-kvm python-guestfs

## 2. Delete default virtual bridge(옵션: 다른 가이드에서 참고)
$ virsh net-destroy default
$ virsh net-undefine default
## 3. Enable live migration by updating(옵션: 다른 가이드에서 참고)
    /etc/libvirt/libvirtd.conf 

listen_tls = 0
listen_tcp = 1
auth_tcp = "none"

## 4. Edit libvirtd_opts variable(옵션: 다른 가이드에서 참고) 
    /etc/init/libvirt-bin.conf
    
env libvirtd_opts="-d -l"

## 5. Edit /etc/default/libvirt-bin file(옵션: 다른 가이드에서 참고)

libvirtd_opts="-d -l"

## 6. Restart the libvirt service and dbus to load the new values:(옵션: 다른 가이드에서 참고)

$ service dbus restart && service libvirt-bin restart
$ service dbus status && service libvirt-bin status


## 7. rm /var/lib/nova/nova.sqlite
## 8. conf 파일에 데이터베이스 접속환경 편집
## 9. conf 파일에 rabbitmq 정보 추가
## 10. conf 파일에 vnc 접속환경 정보 추가(이부분은 controller와 다르므로 수작업추가)
   /etc/nova/nova.conf

[DEFAULT]
...
# vnc setting
novnc_enabled=true
novncproxy_base_url=http://211.224.204.156:6080/vnc_auto.html
novncproxy_port=6080
vncserver_proxyclient_address=10.0.0.101
vncserver_listen=0.0.0.0

## 11. conf 파일에 glance 서비스 호스트 추가(이부분은 controller와 다르므로 수작업추가)
[DEFAULT]
...
glance_host=controller

## 12. conf 파일에 network setting 과 metadata 추가(이부분은 controller와 다르므로 수작업추가)
[DEFAULT]
...

# Network settings
network_api_class=nova.network.neutronv2.api.API
neutron_url=http://controller:9696
neutron_auth_strategy=keystone
neutron_admin_tenant_name=service
neutron_admin_username=neutron
neutron_admin_password=neutron
neutron_admin_auth_url=http://controller:35357/v2.0
libvirt_vif_driver=nova.virt.libvirt.vif.LibvirtHybridOVSBridgeDriver
linuxnet_interface_driver=nova.network.linux_net.LinuxOVSInterfaceDriver

#If you want Neutron + Nova Security groups
firewall_driver=nova.virt.firewall.NoopFirewallDriver
security_group_api=neutron
#If you want Nova Security groups only, comment the two lines above and uncomment line -1-.
#-1-firewall_driver=nova.virt.libvirt.firewall.IptablesFirewallDriver

#Metadata
service_neutron_metadata_proxy = True
neutron_metadata_proxy_shared_secret = helloOpenStack
metadata_host = controller
metadata_listen = 0.0.0.0
metadata_listen_port = 8775

# Compute #
compute_driver=libvirt.LibvirtDriver

# Cinder #
volume_api_class=nova.volume.cinder.API
osapi_volume_listen_port=5900
cinder_catalog_info=volume:cinder:internalURL

## 13. nova-compute.conf 파일에 network setting 과 metadata 추가(이부분은 controller와 다르므로 수작업추가)
    /etc/nova/nova-compute.conf

[DEFAULT]
libvirt_type=kvm
compute_driver=libvirt.LibvirtDriver
# libvirt_ovs_bridge=br-int
# libvirt_vif_type=ethernet
# libvirt_vif_driver=nova.virt.libvirt.vif.LibvirtHybridOVSBridgeDriver
# libvirt_use_virtio_for_bridges=True


## 14. nova 서비스 재시작
$ service nova-compute restart
$ cd /etc/init.d/; for i in $( ls nova-* ); do sudo service $i restart; cd /root/;done
$ cd /etc/init.d/; for i in $( ls nova-* ); do sudo service $i status; cd /root/;done

# ------------------------------------------------------------------------------
5-4. 검증
# ------------------------------------------------------------------------------

1. keypair 생성
$ cd ~/
$ ssh-keygen -t rsa -f mykey -N ""
$ nova keypair-add --pub_key mykey.pub mykey
$ nova keypair-list
+-------+-------------------------------------------------+
| Name  | Fingerprint                                     |
+-------+-------------------------------------------------+
| mykey | db:07:ca:3f:77:06:83:96:6a:63:41:bf:6a:c1:56:54 |
+-------+-------------------------------------------------+

2 
$ nova flavor-list
+----+-----------+-----------+------+-----------+------+-------+-------------+-----------+
| ID | Name      | Memory_MB | Disk | Ephemeral | Swap | VCPUs | RXTX_Factor | Is_Public |
+----+-----------+-----------+------+-----------+------+-------+-------------+-----------+
| 1  | m1.tiny   | 512       | 1    | 0         |      | 1     | 1.0         | True      |
| 2  | m1.small  | 2048      | 20   | 0         |      | 1     | 1.0         | True      |
| 3  | m1.medium | 4096      | 40   | 0         |      | 2     | 1.0         | True      |
| 4  | m1.large  | 8192      | 80   | 0         |      | 4     | 1.0         | True      |
| 5  | m1.xlarge | 16384     | 160  | 0         |      | 8     | 1.0         | True      |
+----+-----------+-----------+------+-----------+------+-------+-------------+-----------+

$ nova image-list
+--------------------------------------+--------+--------+--------+
| ID                                   | Name   | Status | Server |
+--------------------------------------+--------+--------+--------+
| e4d8bb62-288a-46fe-a7a3-16bc881d5eab | cirros | ACTIVE |        |
+--------------------------------------+--------+--------+--------+

3. ssh, ping open
$ nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
+-------------+-----------+---------+-----------+--------------+
| IP Protocol | From Port | To Port | IP Range  | Source Group |
+-------------+-----------+---------+-----------+--------------+
| tcp         | 22        | 22      | 0.0.0.0/0 |              |
+-------------+-----------+---------+-----------+--------------+

$ nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
+-------------+-----------+---------+-----------+--------------+
| IP Protocol | From Port | To Port | IP Range  | Source Group |
+-------------+-----------+---------+-----------+--------------+
| icmp        | -1        | -1      | 0.0.0.0/0 |              |
+-------------+-----------+---------+-----------+--------------+

4. vm 생성
$ nova boot --flavor 1 --key_name mykey --image cirros --security_group default cirrOS
+--------------------------------------+--------------------------------------+
| Property                             | Value                                |
+--------------------------------------+--------------------------------------+
| OS-EXT-STS:task_state                | scheduling                           |
| image                                | cirros                               |
| OS-EXT-STS:vm_state                  | building                             |
| OS-EXT-SRV-ATTR:instance_name        | instance-00000006                    |
| OS-SRV-USG:launched_at               | None                                 |
| flavor                               | m1.tiny                              |
| id                                   | 57f3a270-fbdd-4821-b9dd-e8470b9ef3d3 |
| security_groups                      | [{u'name': u'default'}]              |
| user_id                              | e3d28992d84045de9fa631d583f2c799     |
| OS-DCF:diskConfig                    | MANUAL                               |
| accessIPv4                           |                                      |
| accessIPv6                           |                                      |
| progress                             | 0                                    |
| OS-EXT-STS:power_state               | 0                                    |
| OS-EXT-AZ:availability_zone          | nova                                 |
| config_drive                         |                                      |
| status                               | BUILD                                |
| updated                              | 2014-09-28T05:29:01Z                 |
| hostId                               |                                      |
| OS-EXT-SRV-ATTR:host                 | None                                 |
| OS-SRV-USG:terminated_at             | None                                 |
| key_name                             | mykey                                |
| OS-EXT-SRV-ATTR:hypervisor_hostname  | None                                 |
| name                                 | cirrOS                               |
| adminPass                            | JpBgP9vZ4bt8                         |
| tenant_id                            | 384bc9fa63624974a2bbf896be6fb9ce     |
| created                              | 2014-09-28T05:29:01Z                 |
| os-extended-volumes:volumes_attached | []                                   |
| metadata                             | {}                                   |
+--------------------------------------+--------------------------------------+

5. vm 확인
$ nova list
+--------------------------------------+--------+--------+------------+-------------+----------+
| ID                                   | Name   | Status | Task State | Power State | Networks |
+--------------------------------------+--------+--------+------------+-------------+----------+
| 0624f298-83d9-4108-84a8-1d6a47900b91 | cirrOS | ERROR  | None       | NOSTATE     |          |
| 0bdf3079-5a21-4e86-b5fd-7e5d2abc2bfa | cirrOS | ERROR  | None       | NOSTATE     |          |
| 2dda6af4-63ba-4420-8cdc-c4eaf963439a | cirrOS | BUILD  | scheduling | NOSTATE     |          |
| 5601ce0c-3d71-4e73-9753-4d2ef66b1ffb | cirrOS | ERROR  | None       | NOSTATE     |          |
| 57f3a270-fbdd-4821-b9dd-e8470b9ef3d3 | cirrOS | ERROR  | None       | NOSTATE     |          |
| bba32e67-c937-462f-ab94-4c87f0271f5c | cirrOS | ERROR  | None       | NOSTATE     |          |
+--------------------------------------+--------+--------+------------+-------------+----------+
$ nova show cirrOS 
$ nova show 2dda6af4-63ba-4420-8cdc-c4eaf963439a
+--------------------------------------+-----------------------------------------------+
| Property                             | Value                                         |
+--------------------------------------+-----------------------------------------------+
| status                               | BUILD                                         |
| updated                              | 2014-09-28T05:31:01Z                          |
| OS-EXT-STS:task_state                | scheduling                                    |
| OS-EXT-SRV-ATTR:host                 | None                                          |
| key_name                             | mykey                                         |
| image                                | cirros (e4d8bb62-288a-46fe-a7a3-16bc881d5eab) |
| hostId                               |                                               |
| OS-EXT-STS:vm_state                  | building                                      |
| OS-EXT-SRV-ATTR:instance_name        | instance-00000005                             |
| OS-SRV-USG:launched_at               | None                                          |
| OS-EXT-SRV-ATTR:hypervisor_hostname  | None                                          |
| flavor                               | m1.tiny (1)                                   |
| id                                   | 2dda6af4-63ba-4420-8cdc-c4eaf963439a          |
| security_groups                      | [{u'name': u'default'}]                       |
| OS-SRV-USG:terminated_at             | None                                          |
| user_id                              | e3d28992d84045de9fa631d583f2c799              |
| name                                 | cirrOS                                        |
| created                              | 2014-09-28T05:26:32Z                          |
| tenant_id                            | 384bc9fa63624974a2bbf896be6fb9ce              |
| OS-DCF:diskConfig                    | MANUAL                                        |
| metadata                             | {}                                            |
| os-extended-volumes:volumes_attached | []                                            |
| accessIPv4                           |                                               |
| accessIPv6                           |                                               |
| progress                             | 0                                             |
| OS-EXT-STS:power_state               | 0                                             |
| OS-EXT-AZ:availability_zone          | nova                                          |
| config_drive                         |                                               |
+--------------------------------------+-----------------------------------------------+

6. vm 접속

$ ssh cirros@10.0.0.3



################################################################################
#
###     6. Neutron
#
################################################################################

# ------------------------------------------------------------------------------
6-1. 설치(controller node)
# ------------------------------------------------------------------------------

## 1. neutron 데이터베이스 생성

$ mysql -uroot -pohhberry3333 -e "CREATE DATABASE neutron;"
$ mysql -uroot -pohhberry3333 -e "GRANT ALL ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'neutron';"
$ mysql -uroot -pohhberry3333 -e "GRANT ALL ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'neutron';"

## 2. neutron 스키마 생성(LJG: 이건 몰랐네, neutron db-sync는 다르다!!!)
$ neutron-db-manage --config-file /etc/neutron/neutron.conf \
    --config-file /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini \
    upgrade head

## 3. neutron user 생성 및 role 추가
$ keystone user-create --name=neutron --pass=neutron --email=neutron@kt.com
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|  email   |          neutron@kt.com          |
| enabled  |               True               |
|    id    | 07f6c6865aa94b5b8761937aa779c9b0 |
|   name   |             neutron              |
+----------+----------------------------------+

$ keystone user-role-add --user=neutron --tenant=service --role=admin


## 4. neutron 서비스 생성
$ keystone service-create --name=neutron --type=network \
     --description="OpenStack Networking Service"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |   OpenStack Networking Service   |
|      id     | 6de45e2fec5b412ea5eaeca1cb49c5ba |
|     name    |             neutron              |
|     type    |             network              |
+-------------+----------------------------------+

## 5. neutron 서비스 endpoint 생성
$ keystone endpoint-create \
     --service-id 6de45e2fec5b412ea5eaeca1cb49c5ba \
     --publicurl http://controller:9696 \
     --adminurl http://controller:9696 \
     --internalurl http://controller:9696
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
|   adminurl  |      http://controller:9696      |
|      id     | 55c626c559e5432e85aa6384a1614ad5 |
| internalurl |      http://controller:9696      |
|  publicurl  |      http://controller:9696      |
|    region   |            regionOne             |
|  service_id | 6de45e2fec5b412ea5eaeca1cb49c5ba |
+-------------+----------------------------------+

## 6. apt-get -y install neutron-server

## 7. rm /var/lib/neutron/neutron.sqlite

## 8. conf 파일에 데이터베이스 접속환경 편집
   /etc/neutron/neutron.conf
...
[database]
# The SQLAlchemy connection string used to connect to the database
connection = mysql://neutron:neutron@controller/neutron

## 9. conf 파일에 인증서버 접속환경 편집
[keystone_authtoken]
auth_host = controller
auth_port = 35357
auth_protocol = http
admin_tenant_name = service
admin_user = neutron
admin_password = neutron
signing_dir = $state_path/keystone-signing

## 10. conf 파일에 rabbitmq 정보 추가
   /etc/neutron/neutron.conf

rpc_backend = neutron.openstack.common.rpc.impl_kombu
rabbit_host = controller
rabbit_port = 5672
rabbit_password = rabbit

## 11. ini 파일에 인증토큰 정보 추가
   /etc/neutron/api-paste.ini

[filter:authtoken]
paste.filter_factory = keystoneclient.middleware.auth_token:filter_factory
admin_tenant_name = service
admin_user = neutron
admin_password = neutron

## 12. network node에 설정된 plug-in 구성을 여기 controller node에도 동일하게 설정
# LJG: 비록 nnode를 따로 구성하여 controller node가 실질적으로 plugin 을 사용하지 않아도
# controller 에서 동작하는 neutron-server가 제대로 동작하려면 plugin 설정구조를 알고 있어야 한다.

추가 필요

## 13. nova.conf파일에 neutron 설정파일 정보를 추가
    /etc/nova/nova.conf

# neutron setting    
network_api_class=nova.network.neutronv2.api.API
neutron_url=http://controller:9696
neutron_auth_strategy=keystone
neutron_admin_tenant_name=service
neutron_admin_username=neutron
neutron_admin_password=neutron
neutron_admin_auth_url=http://controller:35357/v2.0
linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver
firewall_driver=nova.virt.firewall.NoopFirewallDriver
security_group_api=neutron

## 14. neutron & nova 서비스 재시작
$ service nova-api restart
$ service nova-scheduler restart
$ service nova-conductor restart
$ service neutron-server restart

# ------------------------------------------------------------------------------
6-2. 설치(dedicated network node)
# ------------------------------------------------------------------------------

## 1. apt-get -y install neutron-server neutron-dhcp-agent neutron-plugin-openvswitch-agent neutron-l3-agent

## 2. rm /var/lib/neutron/neutron.sqlite

## 3. Enable packet forwarding and disable packet destination filtering 
#     so that the network node can coordinate traffic for the VMs. 
      /etc/sysctl.conf file, as follows:

net.ipv4.ip_forward=1
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0

$ sysctl -p
$ service networking restart

## 4. conf 파일에 인증전략 추가
   /etc/neutron/neutron.conf

auth_strategy = keystone

## 5. conf 파일에 subnet overlap 허용 설정
   /etc/neutron/neutron.conf

allow_overlapping_ips = True

## 6. conf 파일에 인증서버 접속환경 편집

[keystone_authtoken]
auth_host = controller
auth_port = 35357
auth_protocol = http
admin_tenant_name = service
admin_user = neutron
admin_password = neutron

## 7. conf 파일에 rabbitmq 정보 추가
   /etc/neutron/neutron.conf

rabbit_host = controller
rabbit_userid = guest
rabbit_password = rabbit

## 8. conf 파일에 데이터베이스 접속환경 편집
   /etc/neutron/neutron.conf
...
[database]
# The SQLAlchemy connection string used to connect to the database
connection = mysql://neutron:neutron@controller/neutron

## 9. ini 파일에 인증토큰 정보 추가
   /etc/neutron/api-paste.ini

[filter:authtoken]
paste.filter_factory = keystoneclient.middleware.auth_token:filter_factory
auth_host = controller
auth_uri = http://controller:5000
admin_tenant_name = service
admin_user = neutron
admin_password = neutron:

## 10. neutront plug-in(openvswitch-switch) 설정
$ service openvswitch-switch restart

$ ovs-vsctl add-br br-int

$ ovs-vsctl add-br br-ex
$ ovs-vsctl add-port br-ex eth2

$ ovs-vsctl add-br br-guest
$ ovs-vsctl add-port br-guest eth4

# 이건 cnode에서 필요
#$ ovs-vsctl add-br br-hybrid
#$ ovs-vsctl add-port br-hybrid eth5

$ ovs-vsctl show
    
## 11. dhcp/l3 agent 설정
    /etc/neutron/l3_agent.ini
    /etc/neutron/dhcp_agent.ini

interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
use_namespaces = True

## 12. conf에 OVS 사용토록 설정
    /etc/neutron/neutron.conf

core_plugin = neutron.plugins.openvswitch.ovs_neutron_plugin.OVSNeutronPluginV2

## 13. virtual networking 생성 방식 선택
    /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini

[OVS]
tenant_network_type = vlan
integration_bridge = br-int
network_vlan_ranges = physnet_guest:2001:4000,physnet_hybrid:1:2000,physnet_ext
bridge_mappings = physnet_guest:br-guest,physnet_hybrid:br-hybrid,physnet_ext:br-ex

## 14. conf 파일에 firewall plugin 설정정보 추가
    /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini

[securitygroup]
# Firewall driver for realizing neutron security group function.
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver    

## 15. dhcp agent 설정
    /etc/neutron/dhcp_agent.ini
    
dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq

## 16. metadata 설정    
/etc/nova/nova.conf

[DEFAULT]
neutron_metadata_proxy_shared_secret = helloOpenStack
service_neutron_metadata_proxy = true

/etc/neutron/metadata_agent.ini

[DEFAULT]
auth_url = http://controller:5000/v2.0
auth_region = regionOne
admin_tenant_name = service
admin_user = neutron
admin_password = neutron
nova_metadata_ip = controller
metadata_proxy_shared_secret = helloOpenStack

## 17. 재시작

$ service nova-api restart
$ service neutron-server restart
$ service neutron-dhcp-agent restart
$ service neutron-l3-agent restart
$ service neutron-metadata-agent restart
$ service neutron-plugin-openvswitch-agent restart



# ------------------------------------------------------------------------------
6-3. 설치(dedicated compute node)
# ------------------------------------------------------------------------------

## 1. Enable packet forwarding and disable packet destination filtering 
#     so that the network node can coordinate traffic for the VMs. 
      /etc/sysctl.conf file, as follows:

net.ipv4.ip_forward=1
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0

$ sysctl -p
$ service networking restart

## 2. neutront plug-in(openvswitch-switch) 설정
$ service openvswitch-switch restart

$ ovs-vsctl add-br br-int

# 이건 nnode에서 필요
$ ovs-vsctl add-br br-ex
$ ovs-vsctl add-port br-ex eth2

$ ovs-vsctl add-br br-guest
$ ovs-vsctl add-port br-guest eth4

$ ovs-vsctl add-br br-hybrid
$ ovs-vsctl add-port br-hybrid eth5

$ ovs-vsctl show

## 3. conf 파일 편집

auth_host = controller
admin_tenant_name = service
admin_user = neutron
admin_password = neutron
auth_url = http://controller:35357/v2.0
auth_strategy = keystone
rpc_backend = neutron.openstack.common.rpc.impl_kombu
rabbit_host = controller
rabbit_port = 5672

# Change the following settings if you're not using the default RabbitMQ configuration
#rabbit_userid = guest
rabbit_password = rabbit

[database]
connection = mysql://neutron:neutron@controller/neutron

## 4. ini 파일에 인증토큰 정보 추가
   /etc/neutron/api-paste.ini

[filter:authtoken]
paste.filter_factory = keystoneclient.middleware.auth_token:filter_factory
auth_host = controller
admin_tenant_name = service
admin_user = neutron
admin_password = neutron:

    
## 5. nova.conf파일에 neutron 설정파일 정보를 추가
    /etc/nova/nova.conf

# neutron setting    
network_api_class=nova.network.neutronv2.api.API
neutron_url=http://controller:9696
neutron_auth_strategy=keystone
neutron_admin_tenant_name=service
neutron_admin_username=neutron
neutron_admin_password=neutron
neutron_admin_auth_url=http://controller:35357/v2.0
linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver
firewall_driver=nova.virt.firewall.NoopFirewallDriver
security_group_api=neutron

## 6. conf에 OVS 사용토록 설정
    /etc/neutron/neutron.conf

core_plugin = neutron.plugins.openvswitch.ovs_neutron_plugin.OVSNeutronPluginV2

## 7. virtual networking 생성 방식 선택
    /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini

[OVS]
tenant_network_type = vlan
integration_bridge = br-int
network_vlan_ranges = physnet_guest:2001:4000,physnet_hybrid:1:2000,physnet_ext
bridge_mappings = physnet_guest:br-guest,physnet_hybrid:br-hybrid,physnet_ext:br-ex

## 8. conf 파일에 firewall plugin 설정정보 추가
    /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini

[securitygroup]
# Firewall driver for realizing neutron security group function.
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver    

## 9. restart

$ service nova-compute restart
$ service neutron-plugin-openvswitch-agent restart



################################################################################
#
###     7. Horizon
#
################################################################################


# ------------------------------------------------------------------------------
2-1. Install horizon
# ------------------------------------------------------------------------------

## 1. apt-get -y install memcached libapache2-mod-wsgi openstack-dashboard

## 2. apt-get -y remove --purge openstack-dashboard-ubuntu-theme
















################################################################################
#
###     8. Ceilometer
#
################################################################################

################################################################################
#
###     9. Heat
#
################################################################################

