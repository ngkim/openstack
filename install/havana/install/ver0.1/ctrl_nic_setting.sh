#!/bin/bash



################################################################################
# controller: 1G NIC 4개 -> ubuntu 14.04
#
#   em1(1G)    -> mgmt
#   em2(1G)    -> api internet
#   em3(1G)    
#   em4(1G)    
################################################################################

NIC_CONF=$1
_mgmt_nic=$2
_mgmt_ip=$3
_mgmt_subnet_mask=$4

_api_nic=$5
_api_ip=$6
_api_subnet=$7
_api_gw=$8
_api_dns=$9


controller_NIC_setting() {

    echo '
    # ------------------------------------------------------------------------------
    ### controller_NIC_setting() !!!
    # ------------------------------------------------------------------------------'
    
    mv $NIC_CONF ${NIC_CONF}.org

cat > ${NIC_CONF} <<EOF
# ------------------------------------------------------------------------------
# The loopback network interface
auto lo
iface lo inet loopback

# management network
auto $_mgmt_nic
iface $_mgmt_nic inet static
    address $_mgmt_ip           
    netmask $_mgmt_subnet_mask  
    # gateway 10.0.0.1 # -> 적어주면 routing table에 default gateway로 설정됨

# api network
auto $_api_nic
iface $_api_nic inet static
    address $_api_ip
    netmask $_api_subnet
    gateway $_api_gw
    # dns-* options are implemented by the resolvconf package, if installed
    dns-nameservers $_api_dns       # 8.8.8.8
# ------------------------------------------------------------------------------
EOF

sudo /etc/init.d/networking restart 

echo 'controller nic setting check:: $NIC_CONF'
cat $NIC_CONF

}