#!/bin/bash

source 'tenant-net.ini'

VM_ID=`nova list | awk '/'$TENANT_VM_NAME'/{print $2}'`

echo "nova delete $VM_ID"
nova delete $VM_ID
