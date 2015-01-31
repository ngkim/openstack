#!/bin/bash

for process in $(ls /etc/init/nova* | cut -d'/' -f4 | cut -d'.' -f1)
do
    apt-get -y remove --purge ${process}
done

for process in $(ls /etc/init/neutron* | cut -d'/' -f4 | cut -d'.' -f1)
do
    apt-get -y remove --purge ${process}
done


apt-get -y remove --purge python-nova python-novaclient
apt-get -y remove --purge python-neutron python-neutronclient
apt-get -y remove --purge openvswitch-switch 


rm -rf /etc/nova
rm -rf /etc/neutron

rm -rf /var/log/nova
rm -rf /var/log/neutron

