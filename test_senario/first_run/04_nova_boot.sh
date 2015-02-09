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


nova boot vUTM-test-01 --flavor 2 --image cd756869-7c5c-4dc1-866e-00f1f778275e --nic net-id=07405330-ca1c-4fba-ad9d-ae3e992d8164 --nic net-id=fe524b23-1f5d-4169-8844-bcc3f10dab5e --nic net-id=dfd51075-111f-4eb7-9b56-2a65e9995390 --availability-zone nova --security-groups default

root@controller:~/openstack/test_senario/first_run# neutron net-list | grep test
| dfd51075-111f-4eb7-9b56-2a65e9995390 | test-net-orange                                       | bb3f6c9a-3dd3-4fb7-bfda-78f808c120e9 192.168.20.0/24   |
| fe524b23-1f5d-4169-8844-bcc3f10dab5e | test-net-green                                        | e1a6e752-28d6-48d9-8e08-3b0b2d3527f4 192.168.20.0/24   |

nova boot vUTM-test-ubuntu-01 --flavor 3 --image e33c74ac-676e-4969-addf-fe1a6078a522 --nic net-id=07405330-ca1c-4fba-ad9d-ae3e992d8164 --nic net-id=fe524b23-1f5d-4169-8844-bcc3f10dab5e --nic net-id=dfd51075-111f-4eb7-9b56-2a65e9995390 --availability-zone nova --security-groups default


e33c74ac-676e-4969-addf-fe1a6078a522

nova boot vUTM-test-01 --flavor 3 --image cd756869-7c5c-4dc1-866e-00f1f778275e --nic net-id=07405330-ca1c-4fba-ad9d-ae3e992d8164 --nic net-id=fe524b23-1f5d-4169-8844-bcc3f10dab5e --nic net-id=dfd51075-111f-4eb7-9b56-2a65e9995390 --availability-zone seocho-az --security-groups default