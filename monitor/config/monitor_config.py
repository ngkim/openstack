# -*- coding: utf-8 -*-

###################################################################
#
#   현재는 구성파일을 복잡하게 할 수 있도록 파이썬의 dict 이용
#   추후, yaml을 사용하는 방안도 고려...
#
###################################################################


#
# 서초 국사의 데이터베이스 정보
seocho_db_info = {
    'db_host': '221.151.188.15',
    'id'     : 'root',
    'pw'     : 'ohhberry3333',
    'db'     : 'monitor',
    'port'   : 3306,
    'tag'    : 'seocho'
}

# 감시대상 호스트와 호스트 내부의 콤포넌트 정보
seocho_monitor = {
    # 감시대상 호스트 리스트
    'host_list': ['mnnode', 'cnode01', 'cnode02'],
    
    # 감시대상 호스트 정보
    # prefix: m: management, n: network, c: compute, s: storage
    #         mn: mgmt & network -> controller와 network 기능을 하나의 서버에 설치(비용이슈)
    'mnnode'    : {
        'ip'   : '221.151.188.15', 
        'port' : 22, 
        'id'   : 'root', 
        'pw'   : 'ohhberry3333'
    },
    'cnode01'    : {
        'ip'   : '221.151.188.16', 
        'port' : 22, 
        'id'   : 'root', 
        'pw'   : 'ohhberry3333'
    },
    'cnode02'    : {
        'ip'   : '221.151.188.17', 
        'port' : 22, 
        'id'   : 'root', 
        'pw'   : 'ohhberry3333'
    },
    
    'host_mon' : {
        'cpu'     : 'mpstat',
        #'memory'  : 'ps -eo user,pid,ppid,rss,size,vsize,pmem,pcpu,time,cmd --sort -rss | head -n 11',
        'disk'    : 'df -h',
        'network' : 'iostat'
    },    
        
    # management(controller) 노드 감시대상 콤포넌트
    'mnode_components' : {
        'nova'          : ['nova-api','nova-conductor','nova-scheduler','nova-cert', 
                           'nova-consoleauth','nova-novncproxy'],
        'neutron'       : ['neutron-server'],
        'cinder'        : ['cinder-api', 'cinder-scheduler','cinder-volume'],
        'glance'        : ['glance-api', 'glance-registry'],
        'keystone'      : ['keystone-all'],                                                            
        'cinder_utils'  : ['iscsid', 'tgtd'],
        'horizon_utils' : ['apache2','memcached','django'],
        'message_utils' : ['epmd', 'beam.smp'],
        'db_utils'      : ['mysqld']  
    },
    # network 노드 감시대상 콤포넌트
    'nnode_components' : {
        'neutron'       : ['neutron-openvswitch-agent', 'neutron-dhcp-agent','neutron-l3-agent', 
                           'neutron-metadata-agent','neutron-ns-metadata-proxy'],
        'neutron_utils' : ['dnsmasq','ovsdb-client','ovsdb-server','ovs-vswitchd']
    },
    'mnnode_components' : {
        'nova'          : ['nova-api','nova-conductor','nova-scheduler','nova-cert', 
                           'nova-consoleauth','nova-novncproxy'],
        'neutron'       : ['neutron-server','neutron-openvswitch-agent',
                           'neutron-dhcp-agent','neutron-l3-agent', 
                           'neutron-metadata-agent','neutron-ns-metadata-proxy'],                                   
        'cinder'        : ['cinder-api', 'cinder-scheduler','cinder-volume'],
        'glance'        : ['glance-api', 'glance-registry'],
        'keystone'      : ['keystone-all'],                                                            
        'cinder_utils'  : ['iscsid', 'tgtd'],
        'horizon_utils' : ['apache2','memcached'],
        'message_utils' : ['epmd', 'beam.smp'],
        'db_utils'      : ['mysqld'],
        'neutron_utils' : ['dnsmasq','ovsdb-client','ovsdb-server','ovs-vswitchd']
    },
    # cnode 노드 감시대상 콤포넌트
    'cnode_components'  : {
        'nova'          : ['nova-compute'],
        'neutron'       : ['neutron-openvswitch-agent'],        
        'nova_utils'    : ['libvirt'],
        'neutron_utils' : ['dnsmasq','ovsdb-client','ovsdb-server','ovs-vswitchd']  
    },
    
    'switch_list' : ['aggr_sw', 'tor_sw'],
    'aggr_sw' : {
        'ip'  : '221.151.188.9'
    },
    'tor_sw' : {
        'ip'  : '221.151.188.19'
    },
    'ovs_db_commands' : {
        'dump': 'ovsdb-client dump tcp:%s:6632',
        #$ ovs-vsctl -vjsonrpc --db=tcp:221.151.188.15:6632 add-br br-jingoo
        #$ ovs-vsctl -vjsonrpc --db=tcp:221.151.188.15:6632 del-br br-jingoo        
        #$ ovs-vsctl -vjsonrpc --db=tcp:221.151.188.15:6632 show
        'schema': 'ovsdb-client get-schema --pretty tcp:%s:6632',
        'list-dbs': 'ovsdb-client list-dbs tcp:%s:6632',
        # 'list-tables': 'ovsdb-client list-tables db tcp:ip:6632',
        'list-tables': 'ovsdb-client list-tables %s tcp:%s:6632',
        # ovsdb-client list-columns tcp:ips:6632 db table
        # ovsdb-client list-columns tcp:221.151.188.15:6632 Open_vSwitch Port
        'list-columns': 'ovsdb-client list-columns tcp:%s:6632 %s %s',
        # ovsdb-client monitor tcp:ip:6632 db table
        # ovsdb-client monitor tcp:221.151.188.15:6632 Open_vSwitch Port
        'monitor': 'ovsdb-client monitor tcp:%s:6632 %s %s'
    }      
    
}

"""
 'ovs_vsctl_commands' : {
     'show': 'ovs-vsctl show',
     ovsp='ovs-dpctl show'
     ovap="ovs-appctl fdb/show "
     ovapd="ovs-appctl bridge/dump-flows "
     ovap="ovs-appctl fdb/show "
     ovapd="ovs-appctl bridge/dump-flows "        
     dpfl="ovs-dpctl dump-flows "
     ovsf='ovs-ofctl '
     ovtun="ovs-ofctl dump-flows br-tun"
     ovint="ovs-ofctl dump-flows br-int"        
     dfl="ovs-ofctl -O OpenFlow13 del-flows "
     ovls="ovs-ofctl -O OpenFlow13  dump-flows br-int"
     ofport=" ovs-ofctl -O OpenFlow13 dump-ports br-int"
     del=" ovs-ofctl -O OpenFlow13 del-flows "
     delman=" ovs-vsctl del-manager"
     # Replace the IP with the ODL controller or OVSDB manager address
     addman=" ovs-vsctl set-manager tcp:10.0.2.15:6640"
"""   
   
































