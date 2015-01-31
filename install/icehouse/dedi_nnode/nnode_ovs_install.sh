#! /bin/bash

network_openvswitch_install() {

    echo '
    # ------------------------------------------------------------------------------
    ### network_openvswitch_install() !!!
    # ------------------------------------------------------------------------------'
  
    echo "apt-get -y install linux-headers-`uname -r`"
    apt-get -y install linux-headers-`uname -r`
    
    echo "apt-get -y install \
        ntp ngrep \
        vlan bridge-utils \
        dnsmasq-base dnsmasq-utils \
        openvswitch-switch"
        
    apt-get -y install \
        ntp ngrep \
        vlan bridge-utils \
        dnsmasq-base dnsmasq-utils \
        openvswitch-switch

    echo 'openvswitch-switch 시작 !!!'
    /etc/init.d/openvswitch-switch restart

    echo '>>> check result'
    echo '# ------------------------------------------------------------------------------'    
    dpkg -l | egrep "linux-headers-`uname -r`"
    dpkg -l | egrep "ntp|ngrep|vlan|bridge-utils|dnsmasq-base|dnsmasq-utils|openvswitch-switch"    
    echo '# ------------------------------------------------------------------------------'

}

network_openvswitch_execute() {
    echo '
    # ------------------------------------------------------------------------------
    ### network_openvswitch_execute() !!!
    # ------------------------------------------------------------------------------'
   
    # Edit the /etc/network/interfaces file for eth2
    # ifconfig eth2 0.0.0.0 up
    # ip link set eth2 promisc on
    
    # Edit the /etc/network/interfaces file for eth3
    # ifconfig eth3 0.0.0.0 up
    # ip link set eth3 promisc on
        
    echo '# 5. openvswitch-switch 구성 !!!'
    #br-int will be used for VM integration
    echo "  -> ovs-vsctl add-br $LOG_INT_BR"
    ovs-vsctl add-br $LOG_INT_BR
    
    # guest network
    echo "  -> ovs-vsctl add-br $LOG_PRVT_BR"
    ovs-vsctl add-br $LOG_PRVT_BR
    echo "  -> ovs-vsctl add-port $LOG_PRVT_BR $NTWK_PRVT_NIC"
    ovs-vsctl add-port $LOG_PRVT_BR $NTWK_PRVT_NIC
    
    # external network
    echo "  -> ovs-vsctl add-br $LOG_EXT_BR"
    ovs-vsctl add-br $LOG_EXT_BR
    echo "  -> ovs-vsctl add-port $LOG_EXT_BR $NTWK_EXT_NIC"
    ovs-vsctl add-port $LOG_EXT_BR $NTWK_EXT_NIC
    
    echo '>>> check result'
    echo '# ------------------------------------------------------------------------------'
    ovs-vsctl show
    echo '# ------------------------------------------------------------------------------'
}