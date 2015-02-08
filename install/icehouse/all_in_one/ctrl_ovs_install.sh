#!/bin/bash

openvswitch_install() {

    echo '
    # ------------------------------------------------------------------------------
    ### openvswitch_install() !!!
    # ------------------------------------------------------------------------------'

    echo "apt-get -y install linux-headers-`uname -r`"

    apt-get -y install \
        linux-headers-`uname -r`

    apt-get -y install \
        vlan \
        bridge-utils build-essential \
        dnsmasq-base dnsmasq-utils \
        openvswitch-switch

    echo 'openvswitch-switch 시작 !!!'
    /etc/init.d/openvswitch-switch restart

    echo '>>> check result'
    echo '# ------------------------------------------------------------------------------'
    dpkg -l | egrep "linux-headers-`uname -r`"
    dpkg -l | egrep "vlan|bridge-utils|dnsmasq-base|dnsmasq-utils|openvswitch-switch"
    echo '# ------------------------------------------------------------------------------'

}

openvswitch_execute() {
    echo '
    # ------------------------------------------------------------------------------
    ### openvswitch_execute() !!!
    # ------------------------------------------------------------------------------'
   
    if [ $COM_PRVT_NIC ]; then
        echo
    else
        COM_PRVT_NIC=$COM01_PRVT_NIC
    fi

    if [ $COM_HYBR_NIC ]; then
        echo
    else
        COM_HYBR_NIC=$COM01_HYBR_NIC
    fi

    echo '# openvswitch-switch 구성 !!!'
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
    
    # hybrid network
    echo "  -> ovs-vsctl add-br $LOG_HYBRID_BR"
    ovs-vsctl add-br $LOG_HYBRID_BR
    echo "  -> ovs-vsctl add-port $LOG_HYBRID_BR $COM_HYBR_NIC"
    ovs-vsctl add-port $LOG_HYBRID_BR $COM_HYBR_NIC
 
    echo '>>> check result'
    echo '# ------------------------------------------------------------------------------'
    ovs-vsctl show
    echo '# ------------------------------------------------------------------------------'
}
