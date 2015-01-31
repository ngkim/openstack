#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import json
import pprint
from util.myDBHelper import *
from util.myUtil import *

if len(sys.argv) > 1:
    prog    = sys.argv[0]
    vm_name = sys.argv[1]

    print prog
    print vm_name
    
else:
    print """
        usage:: vm_net vm_name
          ex) vm_net jingoo_utm  
    """
    exit


network_info_example="""
database return value => tuple
('[{"ovs_interfaceid": "49711125-d0b1-47c0-b339-b83c33c6d961", "network": {"bridge": "br-int", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "10.10.10.3"}], "version": 4, "meta": {"dhcp_server": "10.10.10.2"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "8.8.4.4"}, {"meta": {}, "version": 4, "type": "dns", "address": "8.8.8.8"}], "routes": [], "cidr": "10.10.10.0/24", "gateway": {"meta": {}, "version": 4, "type": "gateway", "address": "10.10.10.1"}}], "meta": {"injected": false, "tenant_id": "767bd7be3fd547e383ab3a3887d0de1b"}, "id": "1f909963-f40f-4296-b0c9-92e38bb18980", "label": "global_mgmt_net"}, "devname": "tap49711125-d0", "qbh_params": null, "meta": {}, "address": "fa:16:3e:3e:63:97", "type": "ovs", "id": "49711125-d0b1-47c0-b339-b83c33c6d961", "qbg_params": null}, {"ovs_interfaceid": "10daa9bd-8d05-4648-b150-ce70cc2625d3", "network": {"bridge": "br-int", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "192.168.0.1"}], "version": 4, "meta": {}, "dns": [], "routes": [], "cidr": "192.168.0.0/24", "gateway": {"meta": {}, "version": null, "type": "gateway", "address": null}}], "meta": {"injected": false, "tenant_id": "1387aa897f1e436fa7c12d18c0bdb318"}, "id": "ee2aeb13-405e-4cce-8674-67d4156616c5", "label": "jingoo_green_net"}, "devname": "tap10daa9bd-8d", "qbh_params": null, "meta": {}, "address": "fa:16:3e:03:39:99", "type": "ovs", "id": "10daa9bd-8d05-4648-b150-ce70cc2625d3", "qbg_params": null}, {"ovs_interfaceid": "aef0c8be-3b94-4224-a957-ac72e78d002f", "network": {"bridge": "br-int", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "192.168.0.225"}], "version": 4, "meta": {}, "dns": [], "routes": [], "cidr": "192.168.0.224/27", "gateway": {"meta": {}, "version": null, "type": "gateway", "address": null}}], "meta": {"injected": false, "tenant_id": "1387aa897f1e436fa7c12d18c0bdb318"}, "id": "c0cac2ad-0db2-48e7-b244-f447af88df76", "label": "jingoo_orange_net"}, "devname": "tapaef0c8be-3b", "qbh_params": null, "meta": {}, "address": "fa:16:3e:2f:c5:1e", "type": "ovs", "id": "aef0c8be-3b94-4224-a957-ac72e78d002f", "qbg_params": null}]',)

tytype:  <type 'list'>
  1 => {'ovs_interfaceid': '49711125-d0b1-47c0-b339-b83c33c6d961', 'network': {'bridge': 'br-int', 'label': 'global_mgmt_net', 'meta': {'injected': False, 'tenant_id': '767bd7be3fd547e383ab3a3887d0de1b'}, 'id': '1f909963-f40f-4296-b0c9-92e38bb18980', 'subnets': [{'ips': [{'meta': {}, 'type': 'fixed', 'version': 4, 'address': '10.10.10.3', 'floating_ips': []}], 'version': 4, 'meta': {'dhcp_server': '10.10.10.2'}, 'dns': [{'meta': {}, 'type': 'dns', 'version': 4, 'address': '8.8.4.4'}, {'meta': {}, 'type': 'dns', 'version': 4, 'address': '8.8.8.8'}], 'routes': [], 'cidr': '10.10.10.0/24', 'gateway': {'meta': {}, 'type': 'gateway', 'version': 4, 'address': '10.10.10.1'}}]}, 'devname': 'tap49711125-d0', 'qbh_params': None, 'meta': {}, 'address': 'fa:16:3e:3e:63:97', 'type': 'ovs', 'id': '49711125-d0b1-47c0-b339-b83c33c6d961', 'qbg_params': None}
-----------------------------------
     ovs_interfaceid -> 49711125-d0b1-47c0-b339-b83c33c6d961
             network -> {'bridge': 'br-int', 'label': 'global_mgmt_net', 'meta': {'injected': False, 'tenant_id': '767bd7be3fd547e383ab3a3887d0de1b'}, 'id': '1f909963-f40f-4296-b0c9-92e38bb18980', 'subnets': [{'ips': [{'meta': {}, 'type': 'fixed', 'version': 4, 'address': '10.10.10.3', 'floating_ips': []}], 'version': 4, 'meta': {'dhcp_server': '10.10.10.2'}, 'dns': [{'meta': {}, 'type': 'dns', 'version': 4, 'address': '8.8.4.4'}, {'meta': {}, 'type': 'dns', 'version': 4, 'address': '8.8.8.8'}], 'routes': [], 'cidr': '10.10.10.0/24', 'gateway': {'meta': {}, 'type': 'gateway', 'version': 4, 'address': '10.10.10.1'}}]}
             devname -> tap49711125-d0
          qbh_params -> None
                meta -> {}
             address -> fa:16:3e:3e:63:97
                type -> ovs
                  id -> 49711125-d0b1-47c0-b339-b83c33c6d961
          qbg_params -> None

{ 'address': 'fa:16:3e:3e:63:97',
    'devname': 'tap49711125-d0',
    'id': '49711125-d0b1-47c0-b339-b83c33c6d961',
    'meta': { },
    'network': { 'bridge': 'br-int',
                  'id': '1f909963-f40f-4296-b0c9-92e38bb18980',
                  'label': 'global_mgmt_net',
                  'meta': { 'injected': False,
                             'tenant_id': '767bd7be3fd547e383ab3a3887d0de1b'},
                  'subnets': [ { 'cidr': '10.10.10.0/24',
                                  'dns': [ { 'address': '8.8.4.4',
                                              'meta': { },
                                              'type': 'dns',
                                              'version': 4},
                                            { 'address': '8.8.8.8',
                                              'meta': { },
                                              'type': 'dns',
                                              'version': 4}],
                                  'gateway': { 'address': '10.10.10.1',
                                                'meta': { },
                                                'type': 'gateway',
                                                'version': 4},
                                  'ips': [ { 'address': '10.10.10.3',
                                              'floating_ips': [],
                                              'meta': { },
                                              'type': 'fixed',
                                              'version': 4}],
                                  'meta': { 'dhcp_server': '10.10.10.2'},
                                  'routes': [],
                                  'version': 4}]},
    'ovs_interfaceid': '49711125-d0b1-47c0-b339-b83c33c6d961',
    'qbg_params': None,
    'qbh_params': None,
    'type': 'ovs'},
              
-----------------------------------
  2 => {'ovs_interfaceid': '10daa9bd-8d05-4648-b150-ce70cc2625d3', 'network': {'bridge': 'br-int', 'label': 'jingoo_green_net', 'meta': {'injected': False, 'tenant_id': '1387aa897f1e436fa7c12d18c0bdb318'}, 'id': 'ee2aeb13-405e-4cce-8674-67d4156616c5', 'subnets': [{'ips': [{'meta': {}, 'type': 'fixed', 'version': 4, 'address': '192.168.0.1', 'floating_ips': []}], 'version': 4, 'meta': {}, 'dns': [], 'routes': [], 'cidr': '192.168.0.0/24', 'gateway': {'meta': {}, 'type': 'gateway', 'version': None, 'address': None}}]}, 'devname': 'tap10daa9bd-8d', 'qbh_params': None, 'meta': {}, 'address': 'fa:16:3e:03:39:99', 'type': 'ovs', 'id': '10daa9bd-8d05-4648-b150-ce70cc2625d3', 'qbg_params': None}
-----------------------------------
     ovs_interfaceid -> 10daa9bd-8d05-4648-b150-ce70cc2625d3
             network -> {'bridge': 'br-int', 'label': 'jingoo_green_net', 'meta': {'injected': False, 'tenant_id': '1387aa897f1e436fa7c12d18c0bdb318'}, 'id': 'ee2aeb13-405e-4cce-8674-67d4156616c5', 'subnets': [{'ips': [{'meta': {}, 'type': 'fixed', 'version': 4, 'address': '192.168.0.1', 'floating_ips': []}], 'version': 4, 'meta': {}, 'dns': [], 'routes': [], 'cidr': '192.168.0.0/24', 'gateway': {'meta': {}, 'type': 'gateway', 'version': None, 'address': None}}]}
             devname -> tap10daa9bd-8d
          qbh_params -> None
                meta -> {}
             address -> fa:16:3e:03:39:99
                type -> ovs
                  id -> 10daa9bd-8d05-4648-b150-ce70cc2625d3
          qbg_params -> None

{ 'address': 'fa:16:3e:03:39:99',
    'devname': 'tap10daa9bd-8d',
    'id': '10daa9bd-8d05-4648-b150-ce70cc2625d3',
    'meta': { },
    'network': { 'bridge': 'br-int',
                  'id': 'ee2aeb13-405e-4cce-8674-67d4156616c5',
                  'label': 'jingoo_green_net',
                  'meta': { 'injected': False,
                             'tenant_id': '1387aa897f1e436fa7c12d18c0bdb318'},
                  'subnets': [ { 'cidr': '192.168.0.0/24',
                                  'dns': [],
                                  'gateway': { 'address': None,
                                                'meta': { },
                                                'type': 'gateway',
                                                'version': None},
                                  'ips': [ { 'address': '192.168.0.1',
                                              'floating_ips': [],
                                              'meta': { },
                                              'type': 'fixed',
                                              'version': 4}],
                                  'meta': { },
                                  'routes': [],
                                  'version': 4}]},
    'ovs_interfaceid': '10daa9bd-8d05-4648-b150-ce70cc2625d3',
    'qbg_params': None,
    'qbh_params': None,
    'type': 'ovs'},          
-----------------------------------
  3 => {'ovs_interfaceid': 'aef0c8be-3b94-4224-a957-ac72e78d002f', 'network': {'bridge': 'br-int', 'label': 'jingoo_orange_net', 'meta': {'injected': False, 'tenant_id': '1387aa897f1e436fa7c12d18c0bdb318'}, 'id': 'c0cac2ad-0db2-48e7-b244-f447af88df76', 'subnets': [{'ips': [{'meta': {}, 'type': 'fixed', 'version': 4, 'address': '192.168.0.225', 'floating_ips': []}], 'version': 4, 'meta': {}, 'dns': [], 'routes': [], 'cidr': '192.168.0.224/27', 'gateway': {'meta': {}, 'type': 'gateway', 'version': None, 'address': None}}]}, 'devname': 'tapaef0c8be-3b', 'qbh_params': None, 'meta': {}, 'address': 'fa:16:3e:2f:c5:1e', 'type': 'ovs', 'id': 'aef0c8be-3b94-4224-a957-ac72e78d002f', 'qbg_params': None}
-----------------------------------
     ovs_interfaceid -> aef0c8be-3b94-4224-a957-ac72e78d002f
             network -> {'bridge': 'br-int', 'label': 'jingoo_orange_net', 'meta': {'injected': False, 'tenant_id': '1387aa897f1e436fa7c12d18c0bdb318'}, 'id': 'c0cac2ad-0db2-48e7-b244-f447af88df76', 'subnets': [{'ips': [{'meta': {}, 'type': 'fixed', 'version': 4, 'address': '192.168.0.225', 'floating_ips': []}], 'version': 4, 'meta': {}, 'dns': [], 'routes': [], 'cidr': '192.168.0.224/27', 'gateway': {'meta': {}, 'type': 'gateway', 'version': None, 'address': None}}]}
             devname -> tapaef0c8be-3b
          qbh_params -> None
                meta -> {}
             address -> fa:16:3e:2f:c5:1e
                type -> ovs
                  id -> aef0c8be-3b94-4224-a957-ac72e78d002f
          qbg_params -> None
          
 { 'address': 'fa:16:3e:2f:c5:1e',
    'devname': 'tapaef0c8be-3b',
    'id': 'aef0c8be-3b94-4224-a957-ac72e78d002f',
    'meta': { },
    'network': { 'bridge': 'br-int',
                  'id': 'c0cac2ad-0db2-48e7-b244-f447af88df76',
                  'label': 'jingoo_orange_net',
                  'meta': { 'injected': False,
                             'tenant_id': '1387aa897f1e436fa7c12d18c0bdb318'},
                  'subnets': [ { 'cidr': '192.168.0.224/27',
                                  'dns': [],
                                  'gateway': { 'address': None,
                                                'meta': { },
                                                'type': 'gateway',
                                                'version': None},
                                  'ips': [ { 'address': '192.168.0.225',
                                              'floating_ips': [],
                                              'meta': { },
                                              'type': 'fixed',
                                              'version': 4}],
                                  'meta': { },
                                  'routes': [],
                                  'version': 4}]},
    'ovs_interfaceid': 'aef0c8be-3b94-4224-a957-ac72e78d002f',
    'qbg_params': None,
    'qbh_params': None,
    'type': 'ovs'}          
-----------------------------------

"""


dtag    = "havana"
db_host = "211.224.204.147"
db_host = "211.224.204.156"
db_id   = "root"
db_pw   = "ohhberry3333"
base_db = "nova"
dh      = myRSQL()


def vm_net_detail(vm_name):
    
    query="""
        SELECT network_info 
        FROM nova.vw_vm_inventory 
        WHERE vm_name='%s'
    """ % vm_name
    
    print query

    # conect
    dh.connect(dtag, db_host, db_id, db_pw, base_db)

    rec = dh.one(dtag,query)    # tuple
    print rec
    jlist=json.loads(rec[0])    # json list
    #print "type: ", type(jlist)
    
    cnt=0
    for rec in jlist:    
        print "  %d =>" % (cnt)
        #for key in dict.iterkeys(): ...
        #for value in dict.itervalues(): ...
        #for key, value in dict.iteritems(): ...
        print '-----------------------------------'
        for key, val in rec.iteritems():
            print "%20s -> %s" % (key, val)
        print '-----------------------------------'
        cnt += 1
         
    print "######################"
    
    pp = pprint.PrettyPrinter(indent=2)
    pp.pprint(jlist)
    
    print "######################"
    
    dh.disconn(dtag)

def vm_net_abstract(vm_name):
    
    query="""
        SELECT network_info 
        FROM nova.vw_vm_inventory 
        WHERE vm_name='%s'
    """ % vm_name
    
    print query

    # conect
    dh.connect(dtag, db_host, db_id, db_pw, base_db)

    rec = dh.one(dtag,query)    # tuple
    
    if rec == "":
        print "not yet!!!"
    print "*"*80        
    print rec
    print "*"*80        
    jlist=json.loads(rec[0])    # json list
    #print "type: ", type(jlist)
    
    import collections
    # vm_net = collections.OrderedDict()
    vm_net = {}
    cnt=1
    print '--------------------------------------------------------------'
    print "[%s] vm nic & network info" % vm_name
    print '--------------------------------------------------------------'
    
    for rec in jlist:
        print "%s  type    -> %s" % (cnt, rec["type"])
        print "    network -> %s" % (rec["network"]["label"])
        print "    ovs_id  -> %s" % (rec["id"])        
        print "    nic num -> eth%s" % cnt
        tap = rec["devname"]
        qbr = "qbr%s" % (rec["id"][:11])
        qvb = "qvb%s" % (rec["id"][:11])
        qvo = "qvo%s" % (rec["id"][:11])
        print "    tap     -> %s" % (tap)                
        print "    qbr     -> %s" % (qbr)
        print "    qvb     -> %s" % (qvb)
        print "    qvo     -> %s" % (qvo)
        
        print "    mac     -> %s" % (rec["address"])        
        print "    subnet       "
        for subnet in rec["network"]["subnets"]:
            print "        cidr  -> %s" % (subnet["cidr"])
            #print "        dns   -> %s" % (subnet["dns"])
            #print "        gw    -> %s" % (subnet["gateway"])
            #print "        ips   -> %s" % (subnet["ips"])
            print "        dns"            
            for dns in subnet["dns"]:
                print "            type  -> %s" % (dns["type"])
                print "            addr  -> %s" % (dns["address"])                
            print "        gw"
            print "            type  -> %s" % (subnet["gateway"]["type"])
            print "            addr  -> %s" % (subnet["gateway"]["address"])                
            print "        ips"
            for ip in subnet["ips"]:
                print "            type  -> %s" % (ip["type"])
                print "            addr  -> %s" % (ip["address"])
                print "            floating_ips-> %s" % (ip["floating_ips"])
            
#             ovs_id = rec["id"]
#             vm_net[ovs_id] = rec["id"]
#             vm_net[ovs_id]["nic"] = "eth%s" % cnt
#             vm_net[ovs_id]["tap"] = "tap%s" % rec["id"][:11]
#             vm_net[ovs_id]["qbr"] = "qbr%s" % rec["id"][:11]
#             vm_net[ovs_id]["qvb"] = "qvb%s" % rec["id"][:11]
#             vm_net[ovs_id]["qvo"] = "qvo%s" % rec["id"][:11]
#             vm_net[ovs_id]["mac"] = rec["address"]
#             vm_net[ovs_id]["net"] = rec["network"]["label"]             
#             vm_net[ovs_id][ip] = rec["network"]["subnet"][0]["address"]
        for_havana="""
        print '    ----------------------------------------------------------'
        print '    # bridge hairpin prevent commands'
        print '    ----------------------------------------------------------'
        print "        brctl hairpin %s %s off" % (qbr, tap)
        print "        brctl hairpin %s %s off" % (qbr, qvb)
        print '    ----------------------------------------------------------'
        
        cmd="brctl hairpin %s %s off" % (qbr, tap)
        print "    cmd <<%s>>" % cmd
        print '    ----------------------------------------------------------'
        print exec_cmd(cmd)
        print '    ----------------------------------------------------------'

        cmd="brctl hairpin %s %s off" % (qbr, qvb)
        print "    cmd <<%s>>" % cmd
        print '    ----------------------------------------------------------'
        print exec_cmd(cmd)
        print '    ----------------------------------------------------------'
        """
        
        iptables_example = """
        
        참고사이트::
        https://developer.rackspace.com/blog/software-defined-networks-in-the-havana-release-of-openstack-part-2/
                
        1
        root@havana:~/openstack/havana/bin# iptables -L neutron-openvswi-FORWARD -n -v --line-numbers | grep 7f9f
        Chain neutron-openvswi-FORWARD (1 references)
        num   pkts bytes target     prot opt in     out     source               destination     
        105      0     0 neutron-openvswi-sg-chain  all  --  *      *       0.0.0.0/0            0.0.0.0/0            PHYSDEV match --physdev-out tap7f9f4a23-e9 --physdev-is-bridged
        106      0     0 neutron-openvswi-sg-chain  all  --  *      *       0.0.0.0/0            0.0.0.0/0            PHYSDEV match --physdev-in tap7f9f4a23-e9 --physdev-is-bridged
        
        2
        root@havana:~/openstack/havana/bin# iptables -L neutron-openvswi-sg-chain -n -v --line-numbers | grep 7f9f
        Chain neutron-openvswi-sg-chain (114 references)
        num   pkts bytes target     prot opt in     out     source               destination   
        105      0     0 neutron-openvswi-i7f9f4a23-e  all  --  *      *       0.0.0.0/0            0.0.0.0/0            PHYSDEV match --physdev-out tap7f9f4a23-e9 --physdev-is-bridged
        106      0     0 neutron-openvswi-o7f9f4a23-e  all  --  *      *       0.0.0.0/0            0.0.0.0/0            PHYSDEV match --physdev-in tap7f9f4a23-e9 --physdev-is-bridged


        root@havana:~/openstack/havana/bin# iptables -L neutron-openvswi-s7f9f4a23-e -n -v --line-numbers
        Chain neutron-openvswi-s7f9f4a23-e (1 references)
        num   pkts bytes target     prot opt in     out     source               destination         
        1        0     0 RETURN     all  --  *      *       192.168.0.225        0.0.0.0/0            MAC FA:16:3E:D2:52:84
        2        0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0
       
        
        root@havana:~/openstack/havana/bin# iptables -I neutron-openvswi-s7f9f4a23-e 2 -s 0.0.0.0/0 -d 0.0.0.0/0 -p all -j RETURN        
        root@havana:~/openstack/havana/bin# iptables -L neutron-openvswi-s7f9f4a23-e -n -v --line-numbers
        Chain neutron-openvswi-s7f9f4a23-e (1 references)
        num   pkts bytes target     prot opt in     out     source               destination         
        1        0     0 RETURN     all  --  *      *       192.168.0.225        0.0.0.0/0            MAC FA:16:3E:D2:52:84           
        2        0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0           
        3        0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0   
        
        # LJG: iptables를 아래와 같이 리눅스쉘에서 직접 수행하면 이전 수행내역이 지워지지 않는다.
        #      그러나, openstack에서 vm을 생성한 이후에 이전 VM들의 iptables를 조사하면 지워진다.
        #      이는 openstack이 내부적으로 iptables 정보를 관리하고 있다는 얘기이므로 
        #      어디서 이를 관리하는지 파악하여 그곳에서 수정해야 한다.
        
        iptables -I neutron-openvswi-se075a028-6 2 -s 0.0.0.0/0 -d 0.0.0.0/0 -p all -j RETURN
        iptables-save > iptable-rule; iptables-restore < iptable-rule
        iptables -L neutron-openvswi-se075a028-6 -n
        
        iptables -I neutron-openvswi-s380a5a04-5 2 -s 0.0.0.0/0 -d 0.0.0.0/0 -p all -j RETURN
        iptables-save > iptable-rule; iptables-restore < iptable-rule
        iptables -L neutron-openvswi-s380a5a04-5 -n
        
        iptables -I neutron-openvswi-se50d688a-0 2 -s 0.0.0.0/0 -d 0.0.0.0/0 -p all -j RETURN
        iptables-save > iptable-rule; iptables-restore < iptable-rule
        iptables -L neutron-openvswi-se50d688a-0 -n
        """
        
        
        iptable_chani_name = "neutron-openvswi-s%s" % (rec["id"][:10])
        print '    # firewall forwarding commands'
        print '    ----------------------------------------------------------'         
        print "        iptables -I %s 2 -s %s -d %s -p all -j RETURN" % (iptable_chani_name,'0.0.0.0/0','0.0.0.0/0')
        print "        iptables-save > iptable-rule; iptables-restore < iptable-rule"
        print "        iptables -L %s -n -v --line-numbers" % (iptable_chani_name)
        print '    ----------------------------------------------------------'
        
        cmd="iptables -I %s 2 -s %s -d %s -p all -j RETURN" % (iptable_chani_name,'0.0.0.0/0','0.0.0.0/0')
        print "    cmd <<%s>>" % cmd
        print '    ----------------------------------------------------------'
        print exec_cmd(cmd)
        print '    ----------------------------------------------------------'
        
        
        cmd="iptables-save > iptable-rule; iptables-restore < iptable-rule"
        print "    cmd <<%s>>" % cmd
        print '    ----------------------------------------------------------'
        print exec_cmd(cmd)
        print '    ----------------------------------------------------------'        
        
        
        cmd="iptables -L %s -n -v --line-numbers" % (iptable_chani_name)
        print "    cmd <<%s>>" % cmd
        print '    ----------------------------------------------------------'
        print exec_cmd(cmd)
        print '    ----------------------------------------------------------'
        cnt += 1
         
    print "######################"
    
    dh.disconn(dtag)
    
    return vm_net
    

vm_net = vm_net_abstract(vm_name)
for key, val in vm_net.iteritems():        
    print "%-20s -> %s" % (key, val)    
    






return_sample = """


root@havana:~/openstack/havana/bin# vm_net.py jingoo-utm
./vm_net.py
jingoo-utm

        SELECT network_info 
        FROM nova.vw_vm_inventory 
        WHERE vm_name='jingoo-utm'
    
## [havana] db (host=211.224.204.147, port=3306, user=root, passwd=ohhberry3333, db=nova) connect succ !!
--------------------------------------------------------------
[jingoo-utm] vm nic & network info
--------------------------------------------------------------
1  type    -> ovs
    network -> global_mgmt_net
    ovs_id  -> 43b020ed-c366-4559-ba00-eb171410737f
    nic num -> eth1
    tap     -> tap43b020ed-c3
    qbr     -> qbr43b020ed-c3
    qvb     -> qvb43b020ed-c3
    qvo     -> qvo43b020ed-c3
    mac     -> fa:16:3e:70:ee:ab
    subnet       
        cidr  -> 10.10.10.0/24
        dns
            type  -> dns
            addr  -> 8.8.4.4
            type  -> dns
            addr  -> 8.8.8.8
        gw
            type  -> gateway
            addr  -> 10.10.10.1
        ips
            type  -> fixed
            addr  -> 10.10.10.3
            floating_ips-> []
    ----------------------------------------------------------
    # bridge hairpin prevent commands
    ----------------------------------------------------------
        brctl hairpin qbr43b020ed-c3 tap43b020ed-c3 off
        brctl hairpin qbr43b020ed-c3 qvb43b020ed-c3 off
    ----------------------------------------------------------
    # firewall forwarding commands
    ----------------------------------------------------------
        iptables -I neutron-openvswi-s43b020ed-c 2 -s 0.0.0.0/0 -d 0.0.0.0/0 -p all -j RETURN
        iptables-save > iptable-rule; iptables-restore < iptable-rule
        iptables -L neutron-openvswi-s43b020ed-c -n
    ----------------------------------------------------------
2  type    -> ovs
    network -> jingoo_green_net
    ovs_id  -> b6dad114-25eb-4284-a176-8eebaf769655
    nic num -> eth2
    tap     -> tapb6dad114-25
    qbr     -> qbrb6dad114-25
    qvb     -> qvbb6dad114-25
    qvo     -> qvob6dad114-25
    mac     -> fa:16:3e:eb:0e:55
    subnet       
        cidr  -> 192.168.0.0/24
        dns
        gw
            type  -> gateway
            addr  -> None
        ips
            type  -> fixed
            addr  -> 192.168.0.1
            floating_ips-> []
    ----------------------------------------------------------
    # bridge hairpin prevent commands
    ----------------------------------------------------------
        brctl hairpin qbrb6dad114-25 tapb6dad114-25 off
        brctl hairpin qbrb6dad114-25 qvbb6dad114-25 off
    ----------------------------------------------------------
    # firewall forwarding commands
    ----------------------------------------------------------
        iptables -I neutron-openvswi-sb6dad114-2 2 -s 0.0.0.0/0 -d 0.0.0.0/0 -p all -j RETURN
        iptables-save > iptable-rule; iptables-restore < iptable-rule
        iptables -L neutron-openvswi-sb6dad114-2 -n
    ----------------------------------------------------------
3  type    -> ovs
    network -> jingoo_orange_net
    ovs_id  -> 7f9f4a23-e919-44f9-97b2-dc47ab602500
    nic num -> eth3
    tap     -> tap7f9f4a23-e9
    qbr     -> qbr7f9f4a23-e9
    qvb     -> qvb7f9f4a23-e9
    qvo     -> qvo7f9f4a23-e9
    mac     -> fa:16:3e:d2:52:84
    subnet       
        cidr  -> 192.168.0.224/27
        dns
        gw
            type  -> gateway
            addr  -> None
        ips
            type  -> fixed
            addr  -> 192.168.0.225
            floating_ips-> []
    ----------------------------------------------------------
    # bridge hairpin prevent commands
    ----------------------------------------------------------
        brctl hairpin qbr7f9f4a23-e9 tap7f9f4a23-e9 off
        brctl hairpin qbr7f9f4a23-e9 qvb7f9f4a23-e9 off
    ----------------------------------------------------------
    # firewall forwarding commands
    ----------------------------------------------------------
        iptables -I neutron-openvswi-s7f9f4a23-e 2 -s 0.0.0.0/0 -d 0.0.0.0/0 -p all -j RETURN
        iptables-save > iptable-rule; iptables-restore < iptable-rule
        iptables -L neutron-openvswi-s7f9f4a23-e -n
    ----------------------------------------------------------
######################

"""




















    
