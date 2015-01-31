#! /bin/bash

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
        bridge-utils build-essential\
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

    echo '# openvswitch-switch 구성 !!!'
    #br-int will be used for VM integration
    echo "  -> ovs-vsctl add-br $LOG_INT_BR"
    ovs-vsctl add-br $LOG_INT_BR

    # guest network
    echo "  -> ovs-vsctl add-br $LOG_GUEST_BR"
    ovs-vsctl add-br $LOG_GUEST_BR
    echo "  -> ovs-vsctl add-port $LOG_GUEST_BR $CTRL_GUEST_NIC"
    ovs-vsctl add-port $LOG_GUEST_BR $CTRL_GUEST_NIC

    # external network
    echo "  -> ovs-vsctl add-br $LOG_EXT_BR"
    ovs-vsctl add-br $LOG_EXT_BR
    echo "  -> ovs-vsctl add-port $LOG_EXT_BR $CTRL_EXT_NIC"
    ovs-vsctl add-port $LOG_EXT_BR $CTRL_EXT_NIC

    echo '>>> check result'
    echo '# ------------------------------------------------------------------------------'
    ovs-vsctl show
    echo '# ------------------------------------------------------------------------------'
}