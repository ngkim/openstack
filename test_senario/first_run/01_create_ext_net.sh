#!/bin/bash

EXT_NET="ext-net"
EXT_SUBNET="ext-subnet"
FLOATING_IP_START=211.224.204.133
FLOATING_IP_END=211.224.204.140
EXTERNAL_NETWORK_GATEWAY=211.224.204.129
EXTERNAL_NETWORK_CIDR=211.224.204.128/27

echo 'neutron net-create $EXT_NET --shared --router:external=True'
neutron net-create $EXT_NET --shared --router:external=True

echo 'neutron subnet-create $EXT_NET --name $EXT_SUBNET \
  --allocation-pool start=$FLOATING_IP_START,end=$FLOATING_IP_END \
  --disable-dhcp --gateway $EXTERNAL_NETWORK_GATEWAY $EXTERNAL_NETWORK_CIDR'

neutron subnet-create $EXT_NET --name $EXT_SUBNET \
  --allocation-pool start=$FLOATING_IP_START,end=$FLOATING_IP_END \
  --disable-dhcp --gateway $EXTERNAL_NETWORK_GATEWAY $EXTERNAL_NETWORK_CIDR
