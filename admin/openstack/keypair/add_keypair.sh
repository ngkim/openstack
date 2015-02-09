#!/bin/bash

#-----------------------------------------------------------------------------------------------+
# Namgon Kim (2014.09.13)
#-----------------------------------------------------------------------------------------------+
# OpenStack tenant에게 새로 key pair를 생성하고 해당 파일을 저장
#
# 동작확인
# - 
#-----------------------------------------------------------------------------------------------+

OPENSTACK_CTRL="211.224.204.147"

export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=ohhberry3333
export OS_AUTH_URL=http://${OPENSTACK_CTRL}:5000/v2.0/

usage() {
    echo " >> Description : 주어진 'keyname'을 가진 새로운 key pair를 생성 후 'keyname'.pem 파일 생성"
	echo "    -  Usage    : $0 [key name]"
	echo "    -  Example  : $0 mykey"
	exit 0
}



if [ -z $1 ]; then
	usage
else
	KEY_NAME=$1
fi

# ERROR: Keypair data is invalid: Keypair name contains unsafe characters (HTTP 400)

nova keypair-add $KEY_NAME > ${KEY_NAME}.pem
