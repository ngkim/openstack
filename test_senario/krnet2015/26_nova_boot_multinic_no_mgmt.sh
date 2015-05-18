#!/bin/bash

source 'provider-net.ini'
source '../include/command_util.sh'

# TODO: Tenant ID 옵션 지원

if [ -z ${OS_AUTH_URL+x} ]; then
    source ~/openstack_rc
fi

IMAGE_ID=`glance image-list | awk '/'$VM_IMAGE'/{print $2}'`
NET_MGMT_ID=`neutron net-list | awk '/'$NET_MGMT'/{print $2}'`
NET_WAN_ID=`neutron net-list | awk '/'$NET_WAN'/{print $2}'`
NET_LAN_ID=`neutron net-list | awk '/'$NET_LAN'/{print $2}'`

cmd="neutron subnet-list | awk '/$SBNET_WAN/{print \$2}'"
run_commands_return $cmd
SBNET_WAN_ID=$RET

echo "SBNET_WAN_ID= $SBNET_WAN_ID"

cmd="neutron subnet-list | awk '/$SBNET_LAN/{print \$2}'"
run_commands_return $cmd
SBNET_LAN_ID=$RET

echo "SBNET_LAN_ID= $SBNET_LAN_ID"

cmd="neutron port-list | grep $SBNET_WAN_ID | grep $_IP_WAN | awk '{print \$2}'"
run_commands_return $cmd
WAN_PORT_ID=$RET
if [ -z $WAN_PORT_ID ]; then
  cmd="neutron port-create $NET_WAN_ID --fixed-ip subnet_id=$SBNET_WAN_ID,ip_address=$_IP_WAN | awk '/ id/{print \$4}'"
  run_commands_return $cmd
  WAN_PORT_ID=$RET
  echo "WAN_PORT_ID= $WAN_PORT_ID"
fi

cmd="neutron port-list | grep $SBNET_LAN_ID | grep $_IP_LAN | awk '{print \$2}'"
run_commands_return $cmd
LAN_PORT_ID=$RET
if [ -z $LAN_PORT_ID ]; then
  cmd="neutron port-create $NET_LAN_ID --fixed-ip subnet_id=$SBNET_LAN_ID,ip_address=$_IP_LAN | awk '/ id/{print \$4}'"
  run_commands_return $cmd
  LAN_PORT_ID=$RET
  echo "LAN_PORT_ID= $LAN_PORT_ID"
fi

source "bootstrap/provider_bootstrap_template.sh" \
	"dat/provider-$VM_NAME.dat" \
	$NIC_LAN \
	$IP_LAN \
	$NIC_WAN \
	$IP_WAN \
        $GW_WAN

do_nova_boot() {
	# TODO: 입력값의 오류 확인, empty string일 경우 return
	
    cmd="nova boot $VM_NAME \
        --flavor $VM_FLAVOR_UTM \
        --image $IMAGE_ID \
        --key-name $ACCESS_KEY \
	--nic net-id=$NET_MGMT_ID \
        --availability-zone $AV_ZONE \
        --security-groups default \
        --user-data dat/provider-$VM_NAME.dat"
    
    run_commands $cmd
}

do_nova_boot
#	--nic port-id=$WAN_PORT_ID \
#	--nic port-id=$LAN_PORT_ID \
