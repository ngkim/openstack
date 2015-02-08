#!/bin/bash

source 'tenant-net.ini'

if [ -z ${OS_AUTH_URL+x} ]; then
    source ~/openstack_rc
fi

IMAGE_ID=`glance image-list | awk '/'$IMAGE_NAME'/{print $2}'`
NET_ID=`neutron net-list | awk '/'$TENANT_NET'/{print $2}'`

print_nova_boot() {
    echo "nova boot $TENANT_VM_NAME
        --flavor 2
        --image $IMAGE_ID
        --nic net-id=$NET_ID
        --availability-zone $AV_ZONE
        --security-groups default"
}

do_nova_boot() {
    nova boot $TENANT_VM_NAME \
        --flavor 2 \
        --image $IMAGE_ID \
        --nic net-id=$NET_ID \
        --availability-zone $AV_ZONE \
        --security-groups default
}

do_nova_boot
