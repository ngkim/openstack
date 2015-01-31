#!/bin/bash

#
# cnode 오픈스택 설치시 참조변수들 설정

KEYSTONE_ENDPOINT=$CONTROLLER_HOST
GLANCE_HOST=$CONTROLLER_HOST


MYSQL_HOST=$CONTROLLER_HOST
MYSQL_NOVA_PASS=nova
MYSQL_NEUTRON_PASS=neutron

SERVICE_TENANT=service
NOVA_SERVICE_USER=nova
NOVA_SERVICE_PASS=nova
NEUTRON_SERVICE_USER=neutron
NEUTRON_SERVICE_PASS=neutron

KEYSTONE_CONF=/etc/keystone/keystone.conf 
NOVA_CONF=/etc/nova/nova.conf
NOVA_COMPUTE_CONF=/etc/nova/nova-compute.conf
NOVA_API_PASTE=/etc/nova/api-paste.ini

NEUTRON_CONF=/etc/neutron/neutron.conf
NEUTRON_PLUGIN_ML2_CONF_INI=/etc/neutron/plugins/ml2/ml2_conf.ini

RSYSLOG_CONF=/etc/rsyslog.conf

echo "
--------------------------------------------------------------------------------
 cnode 오픈스택 설치 참조변수 설정내역
--------------------------------------------------------------------------------"
printf "%s\n" "----------------------------------"
printf "%30s -> %s \n" KEYSTONE_ENDPOINT $KEYSTONE_ENDPOINT
printf "%30s -> %s \n" GLANCE_HOST $GLANCE_HOST
printf "%s\n" "----------------------------------"
printf "%30s -> %s \n" MYSQL_HOST $MYSQL_HOST
printf "%30s -> %s \n" MYSQL_NOVA_PASS $MYSQL_NOVA_PASS
printf "%30s -> %s \n" MYSQL_NEUTRON_PASS $MYSQL_NEUTRON_PASS
printf "%s\n" "----------------------------------"
printf "%30s -> %s \n" SERVICE_TENANT $SERVICE_TENANT
printf "%30s -> %s \n" NOVA_SERVICE_USER $NOVA_SERVICE_USER
printf "%30s -> %s \n" NOVA_SERVICE_PASS $NOVA_SERVICE_PASS
printf "%30s -> %s \n" NEUTRON_SERVICE_USER $NEUTRON_SERVICE_USER
printf "%30s -> %s \n" NEUTRON_SERVICE_PASS $NEUTRON_SERVICE_PASS
printf "%s\n" "----------------------------------"
printf "%30s -> %s \n" KEYSTONE_CONF $KEYSTONE_CONF
printf "%30s -> %s \n" NOVA_CONF $NOVA_CONF
printf "%30s -> %s \n" NOVA_COMPUTE_CONF $NOVA_COMPUTE_CONF
printf "%30s -> %s \n" NOVA_API_PASTE $NOVA_API_PASTE
printf "%30s -> %s \n" NEUTRON_CONF $NEUTRON_CONF
printf "%30s -> %s \n" NEUTRON_PLUGIN_ML2_CONF_INI $NEUTRON_PLUGIN_ML2_CONF_INI
printf "%30s -> %s \n" RSYSLOG_CONF $RSYSLOG_CONF
printf "%s\n" "----------------------------------"


#
#   cnode 오픈스택 open-vswitch 설정 변수 

# vlan용 guest network range:
PHY_GUEST_NET=physnet_guest
PHY_GUEST_NET_RANGE=${PHY_GUEST_NET}:2001:4000

# vlan용 hybrid network range
PHY_HYBRID_NET=physnet_hybrid
PHY_HYBRID_NET_RANGE=${PHY_HYBRID_NET}:10:2000

LOG_INT_BR=br-int
LOG_GUEST_BR=br-guest
LOG_HYBRID_BR=br-hybrid


echo "
--------------------------------------------------------------------------------
 오픈스택 open-vswitch 설정내역 
--------------------------------------------------------------------------------"
printf "%s\n" "----------------------------------"
printf "%30s -> %s \n" PHY_GUEST_NET $PHY_GUEST_NET
printf "%30s -> %s \n" PHY_GUEST_NET_RANGE $PHY_GUEST_NET_RANGE
printf "%s\n" "----------------------------------"
printf "%30s -> %s \n" PHY_HYBRID_NET $PHY_HYBRID_NET
printf "%30s -> %s \n" PHY_HYBRID_NET_RANGE $PHY_HYBRID_NET_RANGE
printf "%s\n" "----------------------------------"
printf "%30s -> %s \n" LOG_INT_BR $LOG_INT_BR
printf "%s\n" "----------------------------------"
printf "%30s -> %s \n" LOG_GUEST_BR $LOG_GUEST_BR
printf "%30s -> %s \n" LOG_HYBRID_BR $LOG_HYBRID_BR
echo "--------------------------------------------------------------------------"

#ask_continue_stop