#!/bin/bash

compute_openvswitch_install() {

    echo '
    # ------------------------------------------------------------------------------
    ### compute_openvswitch_install() !!!
    # ------------------------------------------------------------------------------'

    # OpenVSwitch
    echo "  -> apt-get install -y linux-headers-`uname -r` build-essential"
    apt-get -y install linux-headers-`uname -r` build-essential

    echo "  -> apt-get install -y openvswitch-switch"
    apt-get -y install openvswitch-switch

    echo '>>> check result ----------------------------------------------------'
    dpkg -l | egrep "linux-headers-`uname -r` | build-essential"
    dpkg -l | egrep "openvswitch-switch"    
    echo '# --------------------------------------------------------------------'

}

compute_openvswitch_execute() {
    echo '
    # ------------------------------------------------------------------------------
    ### compute_openvswitch_execute() !!!
    # ------------------------------------------------------------------------------'

    echo '# br-int will be used for VM integration'
    # ex) ovs-vsctl add-br br-int
    echo "  -> ovs-vsctl add-br $LOG_INT_BR"
    ovs-vsctl add-br $LOG_INT_BR

    echo '# guest network'
    echo "  -> ovs-vsctl add-br $LOG_GUEST_BR"
    ovs-vsctl add-br $LOG_GUEST_BR
    echo "  -> ovs-vsctl add-port $LOG_GUEST_BR $COM_GUEST_NIC"
    ovs-vsctl add-port $LOG_GUEST_BR $COM_GUEST_NIC

    # hybrid network
    echo "  -> ovs-vsctl add-br $LOG_HYBRID_BR"
    ovs-vsctl add-br $LOG_HYBRID_BR
    echo "  -> ovs-vsctl add-port $LOG_HYBRID_BR $COM_HYBR_NIC"
    ovs-vsctl add-port $LOG_HYBRID_BR $COM_HYBR_NIC

    echo '>>> check result -----------------------------------------------------'
    ovs-vsctl show
    echo '# --------------------------------------------------------------------'
}