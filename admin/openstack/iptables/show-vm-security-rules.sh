#!/bin/bash

CHAIN_PREFIX_IN="neutron-openvswi-i"
CHAIN_PREFIX_OUT="neutron-openvswi-o"
CHAIN_PREFIX_SPOOF="neutron-openvswi-s"

clear

# TODO: 
#       1) Get VM NAME as a parameter 
#       2) and collect list of interface id of the given VM

ITF_ID=("a7cc2829-a")
for itf in ${ITF_ID[*]}; do
  chain_in=${CHAIN_PREFIX_IN}${itf}
  chain_out=${CHAIN_PREFIX_OUT}${itf}
  chain_spoof=${CHAIN_PREFIX_SPOOF}${itf}

  echo " *** $chain_in"
  iptables -L $chain_in -n
  echo ""

  echo " *** $chain_out"
  iptables -L $chain_out -n
  echo ""

  echo " *** $chain_spoof"
  iptables -L $chain_spoof -n
  echo ""
done
