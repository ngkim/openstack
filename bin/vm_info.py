#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import json
import pprint

from util.myDBHelper import *
from util.myUtil     import *

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


comment="""
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

            
query="""
    SELECT network_info 
    FROM nova.vw_vm_inventory 
    WHERE vm_name='%s'
""" % vm_name

print query

dh = myRSQL()
dtag    = "havana"
db_host = "211.224.204.147"
db_id   = "root"
db_pw   = "ohhberry3333"
base_db = "nova"
# conect
dh.connect(dtag, db_host, db_id, db_pw, base_db)

# vm_zone, vm_host, vm_host_infos, vm_name, vm_start_dt, project_name, vm_sequrity_group_info, user_name, vm_user_keypair_fingerprints, vm_user_keypair_public_key, user_password, user_info, vm_power_state_code, vm_power_state, vm_state, vm_instance_type, vm_vcpus, vm_memory(MB), vm_swap, vm_vcpu_weight, vm_rxtx_factor, vm_root(GB), vm_vol_count, vm_vol_size_sum(GB), vm_vol_names, vm_vol_sizes(GB), vm_vol_locs, vm_system_meta_infos, vm_nic_count, vm_macs, vm_ips, vm_networks, vm_devices_owners, vm_net_cidrs, vm_net_gw_ips, network_info, vm_root, vm_task_state, image_name, image_size(GB),

# vm_zone, vm_host, vm_name, vm_start_dt, project_name, user_name, 
# user_info, vm_power_state, vm_state, vm_sequrity_group_info, 
# vm_instance_type, vm_vcpus, vm_memory(MB), vm_swap, vm_vcpu_weight, 
# vm_rxtx_factor, vm_root(GB), vm_vol_count, vm_vol_size_sum(GB), 
# vm_vol_names, vm_vol_sizes(GB), vm_vol_locs, vm_system_meta_infos, 
# vm_nic_count, vm_macs, vm_ips, vm_networks, vm_devices_owners, vm_net_cidrs, 
# vm_net_gw_ips, network_info, vm_root, 
# image_name, image_size(GB)

query="""
    SELECT 
        vm_zone, vm_host, vm_name, vm_start_dt, project_name, user_name, 
        user_info, vm_power_state, vm_state, vm_sequrity_group_info, 
        vm_instance_type, vm_vcpus, 'vm_memory(MB)', vm_swap, vm_vcpu_weight, 
        vm_rxtx_factor, 'vm_root(GB)', vm_vol_count, 'vm_vol_size_sum(GB)', 
        vm_vol_names, 'vm_vol_sizes(GB)', vm_vol_locs, vm_system_meta_infos, 
        vm_nic_count, vm_macs, vm_ips, vm_networks, vm_devices_owners, vm_net_cidrs, 
        vm_net_gw_ips, network_info, vm_root, 
        image_name, 'image_size(GB)'
    FROM 
        nova.vw_vm_inventory 
    WHERE 
        vm_name='%s'
""" % vm_name

recs= dh.allwithcolnames(dtag, query)
print dh.colheader(dtag)
pp = pprint.PrettyPrinter(indent=4)
# pp.pprint(recs)

cnt=0
for rec in recs:
    cnt += 1
    print "  %d => " % (cnt)
    #for key in dict.iterkeys(): ...
    #for value in dict.itervalues(): ...
    #for key, value in dict.iteritems(): ...
    print '-----------------------------------'
    for key, val in rec.iteritems():        
        if key in "network_info":
            print "%-20s -> " % (key)
            jlist=json.loads(val)
            pp.pprint(jlist)
            #myprint(jlist)
        else:
            print "%-20s -> %s" % (key, val)    
    print '-----------------------------------'
    
dh.disconn(dtag)


