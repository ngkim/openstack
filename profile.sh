#!/bin/bash

echo '##########################################################################'
echo '# openstack profile'
echo '##########################################################################'

#export PATH=.:~/openstack:~/openstack/bin:~/openstack/monitor:$PATH

source ~/openstack_rc


alias ll='ls -alh'
alias grep='grep -ns'
alias sf1='find . -name "*.*" | xargs grep -ns '
alias sf2='find . -name "*.py" | xargs grep -ns '
alias ipexec='ip netns exec '

alias ch755='chmod 755 *.sh;chmod 755 *.py'
alias cd_os='cd ~/openstack'
alias cd_bin='cd ~/openstack/bin'
alias cd_mon='cd ~/openstack/monitor'
alias cd_inst='cd ~/openstack/install'
alias cd_ts='cd ~/openstack/test_senario'

alias cd_os_conf='cd ~/openstack_conf'
alias cd_os_log='cd ~/openstack_log'
alias cd_os_src='cd ~/openstsck_src'
alias cd_os_dir='cd ~/openstsck_dir'
alias cd_os_sql='cd ~/openstsck_sql'

alias cd_ni='cd /var/lib/nova/instances'
alias cd_gi='cd /var/lib/glance/images'
alias cd_cv='cd /var/lib/cinder/volumes'

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


# source ~/openstack_rc
# source ~/openstack/profile_config.sh
# source ~/openstack/profile_log.sh
# source ~/openstack/profile_src.sh
# source ~/openstack/profile_dir.sh


### OVS Aliases ###
alias novh='nova hypervisor-list'
alias novm='nova-manage service list' 
alias ovstart='sudo /usr/share/openvswitch/scripts/ovs-ctl start' 
alias ovs='sudo ovs-vsctl show'
alias ovsd='sudo ovsdb-client dump'
alias ovsp='sudo ovs-dpctl show'
alias ovsf='sudo ovs-ofctl '
alias logs="sudo journalctl -n 300 --no-pager"
alias ologs="tail -n 300 /var/log/openvswitch/ovs-vswitchd.log"
alias vsh="sudo virsh list"
alias ovap="sudo ovs-appctl fdb/show "
alias ovapd="sudo ovs-appctl bridge/dump-flows "
alias dpfl=" sudo ovs-dpctl dump-flows "
alias ovtun="sudo ovs-ofctl dump-flows br-tun"
alias ovint="sudo ovs-ofctl dump-flows br-int"
alias ovap="sudo ovs-appctl fdb/show "
alias ovapd="sudo ovs-appctl bridge/dump-flows "
alias ovl="sudo ovs-ofctl dump-flows br-int"
alias dfl="sudo ovs-ofctl -O OpenFlow13 del-flows "
alias ovls="sudo ovs-ofctl -O OpenFlow13  dump-flows br-int"
alias dpfl="sudo ovs-dpctl dump-flows "
alias ofport=" sudo ovs-ofctl -O OpenFlow13 dump-ports br-int"
alias del=" sudo ovs-ofctl -O OpenFlow13 del-flows "
alias delman=" sudo ovs-vsctl del-manager"
# Replace the IP with the ODL controller or OVSDB manager address
alias addman=" sudo ovs-vsctl set-manager tcp:10.0.2.15:6640"
alias prof="vi ~/.bash_profile"
alias src="source ~/.bashrc"
alias vsh="sudo virsh list"
alias ns="sudo ip netns exec "

################################################################################
#- 명령어 셈플

# ovs-vsctl -vjsonrpc --db=tcp:221.151.188.15:6632 add-br br-jingoo
# ovs-vsctl -vjsonrpc --db=tcp:221.151.188.15:6632 del-br br-jingoo
# ovs-vsctl -vjsonrpc --db=tcp:221.151.188.15:6632 show

# ovsdb-client list-dbs
# ovsdb-client dump tcp:221.151.188.15:6632
# ovsdb-client list-dbs tcp:221.151.188.15:6632
# ovsdb-client get-schema-version tcp:221.151.188.15:6632
# ovsdb-client list-tables tcp:221.151.188.15:6632
# ovsdb-client list-columns Open_vSwitch Port tcp:221.151.188.15:6632
# ovsdb-client list-columns tcp:221.151.188.15:6632 Open_vSwitch Port
# ovsdb-client list-tables tcp:221.151.188.15:6632 Open_vSwitch
# ovsdb-client monitor tcp:221.151.188.15:6632 Open_vSwitch Port

# ps faux -> tree구조로 프로세스 리스트 보여줌 cf) ptree, pstree -G
# nohup python /usr/local/bin/VmServicePortCheck.py -s Backup > /dev/null 2>&1 &
# ovs-vsctl set-manager tcp:10.0.0.101:6640
# dos file -> linux file convert
# vi file -> "1,$ s/{^V}{^M}" 명령과 동일
# dos2unix test.sh
# lshw -c network -short
# ethtool eth0
# rsync -avzh root@211.224.204.132:~/admin ./
# find . -name "*.py" | xargs grep -ns "iptables"
# ip addr show
# watch -d "cat /proc/net/dev | sort -k 1"
# watch -d "cat /proc/interrupts"
# watch -d "cat /proc/meminfo | sort -k 1"
# watch -d "cat /proc/diskstats | sort -k 1"
# dos2unix console-progressbar
# tcpdump -i tap7d3391ef-60 -ne -l arp or icmp
# dhcpdump -i eth7 -ne -l
# iptables에서 filter 조사
# ex) iptables -L neutron-openvswi-s7d3391ef-6 -n -v --line-numbers
# ubuntu에서 설치된 패키지 저장소 :: /var/cache/apt/archives
# 저장된 패키지 내용보는 명령: dpkg -c cinder-api_1%3a2014.1-0ubuntu1.1_all.deb
# ifconfig | awk -F':' '/^eth/{ ethdev=$1; sub(/ .*/, "", ethdev); getline; addr=$2; sub(/ .*/, "", addr); printf "\nauto %s\niface %s inet static\n\taddress %s\n\tnetmask %s\n", ethdev, ethdev, addr, $4 }' | tee -a /etc/network/interfaces
# route | awk ' $1 == "default" { print "\tgateway " $2 }'  | tee -a /etc/network/interfaces
# ip netns exec qrouter-dcdb85e0-3006-4efb-a3a5-4c12e0167af7 ifconfig
# ip netns exec qdhcp-55fde477-efe8-43a5-b721-09929178a4aa pgrep dnsmasq -fl
# ip netns exec qrouter-990e0ac6-4088-4479-b475-30367d5327a4 ssh root@10.0.10.4
# ip netns exec qrouter-dcdb85e0-3006-4efb-a3a5-4c12e0167af7 iptables -L -n
# ip netns exec qrouter-dcdb85e0-3006-4efb-a3a5-4c12e0167af7 iptables -L -n -t nat
# curlcmd = "curl -v -L -s -S -k %s" % (query)
    