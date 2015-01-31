#!/bin/bash

compute_kvm_install() {

    echo '
    # ------------------------------------------------------------------------------
    ### compute_compute_kvm_install_install() !!!
    # ------------------------------------------------------------------------------'

    # OpenVSwitch
    echo "  -> apt-get -y install cpu-checker"
    apt-get -y install cpu-checker
    modprobe kvm_intel

    echo "  -> apt-get -y install kvm libvirt-bin pm-utils"
    apt-get -y install kvm libvirt-bin pm-utils
    
    echo '>>> check result'
    echo '# --------------------------------------------------------------------'
    dpkg -l | egrep "cpu-checker|kvm|libvirt-bin|pm-utils"
    echo '# --------------------------------------------------------------------'

}