#!/bin/bash

file_name=$1
_nic=$2
_ip_cidr=$3
_gw=$4
_gw=${_gw%/*} # get the string before '/' 

cat > $file_name <<EOF
#!/bin/bash

echo "
################################################################################
#
#   VM :: User Data Action
#
################################################################################
"

echo "
# ---------------------------------------------------
# 0. parameters 
# ---------------------------------------------------
"

echo "_nic=     $_nic"
echo "_ip_cidr= $_ip_cidr"
echo "_gw=      $_gw"

echo "
# ---------------------------------------------------
# 1. install tools
# ---------------------------------------------------
"

apt-get -y update  
apt-get -y install iperf ifstat sysstat

echo "
# --------------------------------------------------- 
# 2. nic activate
# ---------------------------------------------------
"
ifconfig $_nic $_ip_cidr up

echo "
# --------------------------------------------------- 
# 3. configure gateway
# ---------------------------------------------------
"
route add -net 221.145.180.0/26 gw $_gw dev $_nic
#route add default gw $_gw dev $_nic

echo "
################################################################################
#
#   End User Data Action
#
################################################################################
"

EOF
