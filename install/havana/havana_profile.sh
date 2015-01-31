#!/bin/bash

echo '##########################################################################'
echo '# inside .habana_profile'
echo '##########################################################################'

export PATH=.:~/openstack:~/openstack/havana:~/openstack/havana/bin:$PATH
source ~/openstack/havana/havana_rc
source ~/openstack/havana/havana_config_profile.sh
source ~/openstack/havana/havana_log_profile.sh
source ~/openstack/havana/havana_src_profile.sh
source ~/openstack/havana/havana_dir_profile.sh

alias ll='ls -alh'
alias dct='~/openstack/delete_cloud_test.sh'

alias ch755='chmod 755 *.sh;chmod 755 *.py'
alias cd_os_src='cd /usr/lib/python2.7/dist-packages'
alias havana_restart='~/openstack/havana/restart_all.sh'
alias cd_os='cd ~/openstack'
alias cd_ha='cd ~/openstack/havana'
alias cd_bin='cd ~/openstack/havana/bin'

alias cd_ice='cd ~/openstack/icehouse'
alias cd_ha_inst='cd ~/openstack/havana/install'
alias cd_ice_inst='cd ~/openstack/icehouse/install'
alias cd_ha_conf='cd ~/openstack/havana/conf'
alias cd_ice_conf='cd ~/openstack/icehouse/conf'
alias cd_ha_log='cd ~/openstack/havana/log'
alias cd_ice_log='cd ~/openstack/icehouse/log'

alias cd_nova_instance='cd /var/lib/nova/instances'                 # cd nova instaces directory on cnode
alias cd_glance_image='cd /var/lib/glance/images'                   # cd glance images directory on controller
alias cd_cinder_volume='cd /var/lib/cinder/volumes'                 # cd cinder volumes directory on controller

alias nsgrep='netstat -naop | grep -v grep | grep'
alias nspython='netstat -naop | grep -v grep | grep python'
alias nsnova='netstat -naop | grep -v grep | grep nova'
alias nsapi='netstat -naop | grep -v grep | grep api'
alias nsglance='netstat -naop | grep -v grep | grep glance'
alias nsneutron='netstat -naop | grep -v grep | grep neutron'
alias nscinder='netstat -naop | grep -v grep | grep cinder'
alias nsovs='netstat -naop | grep -v grep | grep ovs'
alias nsagent='netstat -naop | grep -v grep | grep agent'
alias nsmeta='netstat -naop | grep -v grep | grep meta'

alias psgrep='ps -ef | grep -v grep | grep'
alias pspython='ps -ef | grep -v grep | grep python'
alias psnova='ps -ef | grep -v grep | grep nova'
alias psapi='ps -ef | grep -v grep | grep api'
alias psglance='ps -ef | grep -v grep | grep glance'
alias psneutron='ps -ef | grep -v grep | grep neutron'
alias pscinder='ps -ef | grep -v grep | grep cinder'
alias psovs='ps -ef | grep -v grep | grep ovs'
alias psagent='ps -ef | grep -v grep | grep agent'
alias psmeta='ps -ef | grep -v grep | grep meta'

alias ngrep_horizon='ngrep -qd any port 80'             # horizon monitor
alias ngrep_rabbit='ngrep -qd any port 5672'            # rabbit monitor
alias ngrep_db='ngrep -qd any port 3306'                # db internal monitor
alias ngrep_nova_api='ngrep -qd any port 8774'          # nova api monitor
alias ngrep_cinder_api='ngrep -qd any port 8776'        # cinder api monitor
alias ngrep_glance_api='ngrep -qd any port 9292'        # glance api monitor
alias ngrep_neutron_server='ngrep -qd any port 9696'    # neutron-server monitor

# horizon run as debug mode
alias run_horizon_debug='/usr/share/openstack-dashboard/manage.py runserver 0.0.0.0:8001'

# depth 1 level harddisk usage
# du -h --max-depth=1
alias du='du -h --max-depth=1'

# dos file -> linux file convert
# vi file -> "1,$ s/{^V}{^M}" 명령과 동일
# dos2unix test.sh
# lshw -c network -short
# ethtool eth0
# rsync -avzh root@211.224.204.132:~/admin ./
# find . -name "*.py" | xargs grep -n "iptables"
# ip addr show
# watch -d "cat /proc/net/dev | sort -k 1"
# watch -d "cat /proc/interrupts"
# watch -d "cat /proc/meminfo | sort -k 1"
# watch -d "cat /proc/diskstats | sort -k 1"
# dos2unix console-progressbar
# tcpdump -i tap7d3391ef-60 -ne -l arp or icmp
# dhcpdump -i eth7 -ne -l
# iptables에서 filter 조사
# ex) iptables -L neutron-openvswi-s7d3391ef-6 -n

