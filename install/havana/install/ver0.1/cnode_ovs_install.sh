#!/bin/bash

compute_openvswitch_install() {

    echo '
    # ------------------------------------------------------------------------------
    ### compute_openvswitch_install() !!!
    # ------------------------------------------------------------------------------'
    
    echo "  -> sudo apt-get install -y openvswitch-switch"
    apt-get -y install openvswitch-switch

    /etc/init.d/openvswitch-switch restart

    echo '>>> check result'
    echo '# --------------------------------------------------------------------'
    dpkg -l | egrep "openvswitch-switch"    
    echo '# --------------------------------------------------------------------'

}


compute_openvswitch_execute() {
    echo '
    # ------------------------------------------------------------------------------
    ### compute_openvswitch_execute() !!!
    # ------------------------------------------------------------------------------'

    echo '# br-int will be used for VM integration'
    # ex) sudo ovs-vsctl add-br br-int
    echo "  -> sudo ovs-vsctl add-br $LOG_INT_BR"
    sudo ovs-vsctl add-br $LOG_INT_BR

    echo '# private network'
    echo "  -> sudo ovs-vsctl add-br $LOG_PRVT_BR"
    sudo ovs-vsctl add-br $LOG_PRVT_BR
    echo "  -> sudo ovs-vsctl add-port $LOG_PRVT_BR $COM_PRVT_NIC"
    sudo ovs-vsctl add-port $LOG_PRVT_BR $COM_PRVT_NIC

    # hybrid network
    echo "  -> sudo ovs-vsctl add-br $LOG_HYBRID_BR"
    sudo ovs-vsctl add-br $LOG_HYBRID_BR
    echo "  -> sudo ovs-vsctl add-port $LOG_HYBRID_BR $COM_HYBR_NIC"
    sudo ovs-vsctl add-port $LOG_HYBRID_BR $COM_HYBR_NIC

    echo '>>> check result'
    echo '# --------------------------------------------------------------------'
    sudo ovs-vsctl show
    echo '# --------------------------------------------------------------------'
}