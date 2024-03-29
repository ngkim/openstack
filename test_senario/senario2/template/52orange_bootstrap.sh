#!/bin/bash

echo "
################################################################################
#
#   Orange Client VM :: User Data Action
#
################################################################################
"

# ToDo List
# 근본적으로는 3, 4, 5번이 리부팅이 되어도 실행되게 해야함.
# 그리고 vm을 생성할때 IP를 고정시켜야 함. 그래야 5번이 확실함.

echo "
# ---------------------------------------------------
# 1. install bridge-utils to use brctl commands
# ---------------------------------------------------
"

apt-get -y update
apt-get -y install bridge-utils    
apt-get -y install iperf

echo "
# --------------------------------------------------- 
# 2. orange nic activate & attach IP
# ---------------------------------------------------
"
# orange nic 
#ifconfig eth1 192.168.0.226 netmask 255.255.255.224 up
#ifconfig eth1 192.168.0.226 netmask 255.255.255.0 up
ifconfig eth1 192.168.0.222 netmask 255.255.255.0 up

echo "
# --------------------------------------------------- 
# 3. iperf -s 실행
# ---------------------------------------------------
"
# nohup python /usr/local/bin/VmServicePortCheck.py > /dev/null 2>&1 &
nohup /usr/bin/iperf -s > /dev/null &2>1 &
        
echo "
################################################################################
#
#   End User Data Action
#
################################################################################
"
            