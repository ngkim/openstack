#!/bin/bash

echo "
################################################################################
#
#   Start User Data Action
#
################################################################################
"

cat > /etc/hostname <<EOF
leejingoo
EOF

echo "
    net.ipv4.ip_forward=1
    net.ipv4.conf.all.rp_filter=0
    net.ipv4.conf.default.rp_filter=0" | tee -a /etc/sysctl.conf

# sed -i "s/^bind\-address.*/bind-address = 0.0.0.0/g" $MY_SQL_CONF

hostname

mkdir ~/openstack

# sudo apt-get -y install ipcalc dhcpdump htop tcpdump lsof ngrep ncat dstat
# dpkg -l
    
echo "
################################################################################
#
#   End User Data Action
#
################################################################################
"
            