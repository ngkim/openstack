#!/usr/bin/python
# -*- coding: utf-8 -*-

import os, traceback, time

import config.monitor_config  # config 정보파일을 import
import sql.sql_collection   # sql 패키지 로딩
import collections, json

import sys
import collections
from pysnmp.entity.rfc3413.oneliner import cmdgen

from helper.pyramikoHelper  import myParamiko
from helper.dbHelper        import myRSQL
from helper.logHelper       import myLogger
from compiler.ast import Node

log = myLogger(tag='switch_monitor', logdir='./log', loglevel='debug', logConsole=True).get_instance()

"""
먼저, SNMP_Port_Status()를 호출해서
switch port가 연결되어 있는 포트에 대해서만 상태정보를 구한다.
"""
                        
class SNMP_Port_Status():
    
    def __init__(self, switch, ip, community):
        
        self.switch     = switch
        self.ip         = ip
        self.community  = community
        self.key = "%s-%s" % (ip, switch)
        self.enable_ports = {}
        self.enable_ports[self.key] = []

    def datafrommib(self, mib, community, ip):
            value = tuple([int(i) for i in mib.split('.')])
            generator = cmdgen.CommandGenerator()
            comm_data = cmdgen.CommunityData('server', community, 1) # 1 means version SNMP v2c
            transport = cmdgen.UdpTransportTarget((ip, 161))
        
            real_fun = getattr(generator, 'nextCmd')
            res = (errorIndication, errorStatus, errorIndex, varBindTable)\
                    = real_fun(comm_data, transport, value)
        
            if not errorIndication is None  or errorStatus is True:
                   log.debug( "Error: %s %s %s %s" % res )
                   yield None
            else:
                for varBindTableRow in varBindTable:
                    data = varBindTableRow[0]
                    port = data[0]._value[len(value):]
                    octets = data[1]
        
                    yield {'port': port[0], 'octets': octets}
    
    def status(self, ip, community):
        # for use snmptool try:
        # snmpwalk -c mymypub -v2c <ip> <mib>
        # e.t.c...
        mibs = [('1.3.6.1.2.1.2.2.1.8', 'ifOperStatus'),
                ('1.3.6.1.2.1.2.2.1.3', 'ifType'),
                ('1.3.6.1.2.1.2.2.1.5', 'ifSpeed'),
                ('1.3.6.1.2.1.31.1.1.1.1', 'ifName')                
                ]
                #('1.3.6.1.2.1.31.1.1.1.18', 'ifAlias')
    
        ports = collections.defaultdict(dict)
    
        for mib in mibs:
            data = self.datafrommib(mib[0], community, ip)
            for row in data:
                if row:
                    ports[row['port']][mib[1]] = row['octets']
                else:
                    return None
    
        return ports
   
    def ifType_description(self):
        """
        
        Object      ifType
        OID         1.3.6.1.2.1.2.2.1.3
        
        Type        IANAifType 
                    1:other
                    2:regular1822
                    3:hdh1822
                    4:ddnX25
                    5:rfc877x25
                    6:ethernetCsmacd
                    7:iso88023Csmacd
                    8:iso88024TokenBus
                    9:iso88025TokenRing
                    10:iso88026Man
                    11:starLan
                    12:proteon10Mbit
                    13:proteon80Mbit
                    14:hyperchannel
                    15:fddi
                    16:lapb
                    17:sdlc
                    18:ds1
                    19:e1
                    20:basicISDN
                    21:primaryISDN
                    22:propPointToPointSerial
                    23:ppp
                    24:softwareLoopback
                    25:eon
                    26:ethernet3Mbit
                    27:nsip
                    28:slip
                    29:ultra
                    30:ds3
                    31:sip
                    32:frameRelay
                    33:rs232
                    34:para
                    35:arcnet
                    36:arcnetPlus
                    37:atm
                    38:miox25
                    39:sonet
                    40:x25ple
                    41:iso88022llc
                    42:localTalk
                    43:smdsDxi
                    44:frameRelayService
                    45:v35
                    46:hssi
                    47:hippi
                    48:modem
                    49:aal5
                    50:sonetPath
                    51:sonetVT
                    52:smdsIcip
                    53:propVirtual
                    54:propMultiplexor
                    55:ieee80212
                    56:fibreChannel
                    57:hippiInterface
                    58:frameRelayInterconnect
                    59:aflane8023
                    60:aflane8025
                    61:cctEmul
                    62:fastEther
                    63:isdn
                    64:v11
                    65:v36
                    66:g703at64k
                    67:g703at2mb
                    68:qllc
                    69:fastEtherFX
                    70:channel
                    71:ieee80211
                    72:ibm370parChan
                    73:escon
                    74:dlsw
                    75:isdns
                    76:isdnu
                    77:lapd
                    78:ipSwitch
                    79:rsrb
                    80:atmLogical
                    81:ds0
                    82:ds0Bundle
                    83:bsc
                    84:async
                    85:cnr
                    86:iso88025Dtr
                    87:eplrs
                    88:arap
                    89:propCnls
                    90:hostPad
                    91:termPad
                    92:frameRelayMPI
                    93:x213
                    94:adsl
                    95:radsl
                    96:sdsl
                    97:vdsl
                    98:iso88025CRFPInt
                    99:myrinet
                    100:voiceEM
                    101:voiceFXO
                    102:voiceFXS
                    103:voiceEncap
                    104:voiceOverIp
                    105:atmDxi
                    106:atmFuni
                    107:atmIma
                    108:pppMultilinkBundle
                    109:ipOverCdlc
                    110:ipOverClaw
                    111:stackToStack
                    112:virtualIpAddress
                    113:mpc
                    114:ipOverAtm
                    115:iso88025Fiber
                    116:tdlc
                    117:gigabitEthernet
                    118:hdlc
                    119:lapf
                    120:v37
                    121:x25mlp
                    122:x25huntGroup
                    123:trasnpHdlc
                    124:interleave
                    125:fast
                    126:ip
                    127:docsCableMaclayer
                    128:docsCableDownstream
                    129:docsCableUpstream
                    130:a12MppSwitch
                    131:tunnel
                    132:coffee
                    133:ces
                    134:atmSubInterface
                    135:l2vlan
                    136:l3ipvlan
                    137:l3ipxvlan
                    138:digitalPowerline
                    139:mediaMailOverIp
                    140:dtm
                    141:dcn
                    142:ipForward
                    143:msdsl
                    144:ieee1394
                    145:if-gsn
                    146:dvbRccMacLayer
                    147:dvbRccDownstream
                    148:dvbRccUpstream
                    149:atmVirtual
                    150:mplsTunnel
                    151:srp
                    152:voiceOverAtm
                    153:voiceOverFrameRelay
                    154:idsl
                    155:compositeLink
                    156:ss7SigLink
                    157:propWirelessP2P
                    158:frForward
                    159:rfc1483
                    160:usb
                    161:ieee8023adLag
                    162:bgppolicyaccounting
                    163:frf16MfrBundle
                    164:h323Gatekeeper
                    165:h323Proxy
                    166:mpls
                    167:mfSigLink
                    168:hdsl2
                    169:shdsl
                    170:ds1FDL
                    171:pos
                    172:dvbAsiIn
                    173:dvbAsiOut
                    174:plc
                    175:nfas
                    176:tr008
                    177:gr303RDT
                    178:gr303IDT
                    179:isup
                    180:propDocsWirelessMaclayer
                    181:propDocsWirelessDownstream
                    182:propDocsWirelessUpstream
                    183:hiperlan2
                    184:propBWAp2Mp
                    185:sonetOverheadChannel
                    186:digitalWrapperOverheadChannel
                    187:aal2
                    188:radioMAC
                    189:atmRadio
                    190:imt
                    191:mvl
                    192:reachDSL
                    193:frDlciEndPt
                    194:atmVciEndPt
                    195:opticalChannel
                    196:opticalTransport
                    197:propAtm
                    198:voiceOverCable
                    199:infiniband
                    200:teLink
                    201:q2931
                    202:virtualTg
                    203:sipTg
                    204:sipSig
                    205:docsCableUpstreamChannel
                    206:econet
                    207:pon155
                    208:pon622
                    209:bridge
                    210:linegroup
                    211:voiceEMFGD
                    212:voiceFGDEANA
                    213:voiceDID
                    214:mpegTransport
                    215:sixToFour
                    216:gtp
                    217:pdnEtherLoop1
                    218:pdnEtherLoop2
                    219:opticalChannelGroup
                    220:homepna
                    221:gfp
                    222:ciscoISLvlan
                    223:actelisMetaLOOP
                    224:fcipLink
                    225:rpr
                    226:qam
                    227:lmp
                    228:cblVectaStar
                    229:docsCableMCmtsDownstream
                    230:adsl2
                    231:macSecControlledIF
                    232:macSecUncontrolledIF
                    233:aviciOpticalEther
                    234:atmbond
        Permission  read-only
        Status      current
        Description    
                    The type of interface. Additional values for ifType are
                    assigned by the Internet Assigned Numbers Authority (IANA),
                    through updating the syntax of the IANAifType textual
                    convention.
        """
        
    def ifOperStatus_description(self):
        """
        Object      ifOperStatus
        OID         1.3.6.1.2.1.2.2.1.8
        Type        INTEGER
        Permission  read-only
        Status      current
        Values      1 : up
                    2 : down
                    3 : testing
                    4 : unknown
                    5 : dormant
                    6 : notPresent
                    7 : lowerLayerDown        
        Description    
                    The current operational state of the interface. The
                    testing(3) state indicates that no operational packets can
                    be passed. If ifAdminStatus is down(2) then ifOperStatus
                    should be down(2). If ifAdminStatus is changed to up(1)
                    then ifOperStatus should change to up(1) if the interface is
                    ready to transmit and receive network traffic; it should
                    change to dormant(5) if the interface is waiting for
                    external actions (such as a serial line waiting for an
                    incoming connection); it should remain in the down(2) state
                    if and only if there is a fault that prevents it from going
                    to the up(1) state; it should remain in the notPresent(6)
                    state if the interface has missing (typically, hardware)
                    components.
        """
            
    def run(self):
    
        log.debug( "#"*60 )
        log.debug( "%s : %s switch port status" % (self.switch, self.ip) )
        log.debug( "#"*60 )
            
        ports = self.status(self.ip, self.community)
        if ports:            
            for key, value in ports.items():                
                """
                ex) 1 => {'ifSpeed': Gauge32(1000000000), 'ifName': OctetString('Ethernet1'), 'ifType': Integer(6), 'ifOperStatus': Integer(1)}
                """
                if value['ifOperStatus'] == 6:
                    # interface not Present
                    continue
                
                # 현재 스위치에 연결된 포트만 찾는다.    
                self.enable_ports[self.key].append(key)
                
                status = ( '  ' + '%-8s' % key + (' ifOperStatus: %(ifOperStatus)s ifType: %(ifType)4s' +\
                            ' ifSpeed: %(ifSpeed)12s ifName: %(ifName)13s' ) % value )
                #log.debug( "%s => %s" % (key, value) )
                log.debug( status )
        
        print self.enable_ports[self.key]


class SNMP_Port_Traffic():
    
    def __init__(self, switch, ip, community):
        
        self.switch     = switch
        self.ip         = ip
        self.community  = community
        
    
    def datafrommib(self, mib, community, conn):
        value = tuple([int(i) for i in mib.split('.')])
        #res = (errorIndication, errorStatus, errorIndex, varBindTable)\
        #        = real_fun(comm_data, transport, value)
        res = (errorIndication, errorStatus, errorIndex, varBindTable)\
                = conn[3](conn[1], conn[2], value)
    
        if not errorIndication is None  or errorStatus is True:
               log.debug( "Error: %s %s %s %s" % res)
               yield None
        else:
            for varBindTableRow in varBindTable:
                # varBindTableRow:
                #   in: [(ObjectName(1.3.6.1.2.1.2.2.1.10.8), Counter32(180283794))]
                data = varBindTableRow[0]
                port = data[0]._value[len(value):]
                octets = data[1]
    
                yield {'port': port[0], 'octets': octets}

    def load(self, ip, community):
        # for use snmptool try:
        # In: snmpwalk -c mymypub -v2c <ip> 1.3.6.1.2.1.2.2.1.10.2
        # Out: snmpwalk -c mymypub -v2c <ip> 1.3.6.1.2.1.2.2.1.16.2
        # e.t.c...
        generator = cmdgen.CommandGenerator()
        comm_data = cmdgen.CommunityData('server', community, 1) # 1 means version SNMP v2c
        transport = cmdgen.UdpTransportTarget((ip, 161))
        real_fun = getattr(generator, 'nextCmd')
        conn = (generator, comm_data, transport, real_fun)
        mibs = [('1.3.6.1.2.1.2.2.1.16', 'out'),
                ('1.3.6.1.2.1.2.2.1.10', 'in'),
                ('1.3.6.1.2.1.2.2.1.11', 'ucast'),
                ('1.3.6.1.2.1.2.2.1.12', 'nucast'),
                ('1.3.6.1.2.1.2.2.1.13', 'discards'),
                ('1.3.6.1.2.1.2.2.1.14', 'errors')]
    
        ports = collections.defaultdict(dict)
    
        for mib in mibs:
            data = self.datafrommib(mib[0], community, conn)
            for row in data:
                if row:
                    ports[row['port']][mib[1]] = int(row['octets'])
                else:
                    return None
    
        return ports

    def run(self):
        
        log.debug( "#"*60 )
        log.debug( "%s : %s switch port traffic" % (self.switch, self.ip) )
        log.debug( "#"*60 )
                
        # == debug ==
        #import profile
        #profile.run("load('%s', '%s')" % (ip, community))
        ports = self.load(self.ip, self.community)
        if ports:
            for key, value in ports.items():
                """
                ex) 1 => {'discards': 2, 'errors': 0, 'nucast': 26, 'ucast': 99261858, 'in': 3601870395, 'out': 3719859329}
                """
                
                traffic = ('in: %(in)s out: %(out)s ucast: %(ucast)s' +\
                           ' nucast: %(nucast)s discards: %(discards)s' +\
                           ' errors: %(errors)s') % value                
                # log.debug( "  %s => %s" % (key, value) )
                log.debug( "%s => %s" % (key, traffic) )
   
   

class SNMP_Port_DB():
    
    def __init__(self, switch, ip, community):
        
        self.switch     = switch
        self.ip         = ip
        self.community  = community
    
    def fetchFdb(self, ip, community):
        mib = '1.3.6.1.2.1.17.7.1.2.2.1.2'
        value = tuple([int(i) for i in mib.split('.')])
        generator = cmdgen.CommandGenerator()
        comm_data = cmdgen.CommunityData('server', community, 1) # 1 means version SNMP v2c
        transport = cmdgen.UdpTransportTarget((ip, 161))
    
        real_fun = getattr(generator, 'nextCmd')
        res = (errorIndication, errorStatus, errorIndex, varBindTable)\
            = real_fun(comm_data, transport, value)
    
        if not errorIndication is None  or errorStatus is True:
               log.debug( "Error: %s %s %s %s" % res )
        else:
            for varBindTableRow in varBindTable:
                # varBindTableRow:
                #     [(ObjectName(1.3.6.1.2.1.17.7.1.2.2.1.2.5.0.27.144.212.92.45),
                #     Integer(27))]
    
                data = varBindTableRow[0][0]._value[len(value):]
    
                vlan = data[0]
                #mac = '%s' % ':'.join([hex(int(i))[2:] for i in data[-6:]])
                mac = '%02x:%02x:%02x:%02x:%02x:%02x' % tuple(map(int, data[-6:]))
                port = varBindTableRow[0][1]
                yield {'vlan': vlan, 'mac': mac, 'port': port}    
            
    def run(self):
    
        log.debug( "#"*60 )
        log.debug( "%s : %s switch port db" % (self.switch, self.ip) )
        log.debug( "#"*60 )
            
        for fdb in self.fetchFdb(self.ip, self.community):
            """
            ex) {'mac': 'a0:d3:c1:f2:92:9c', 'vlan': 4, 'port': Integer(2)}
            """          
            #log.debug(fdb)  
            log.debug( '  vlan: %(vlan)4s mac: %(mac)s port: %(port)s' % (fdb) ) 


        
class SwitchMonitor(object):
    """
    Aggr Switch와 Tor Switch 모니터 정보를 수집한다.
    지금 단계에서는 간단히 폴링을 하지만 나중에는 syslog을 이용해서 
    이벤트로 받아야 하지 않을까?
    """
    
    def __init__(self):
        
        self.org_dir= os.getcwd()
        self.init_config_from_dict_config_file()        
        # self.database_connect()
        
    def __del__(self):
        
        #  데이터베이스를 정리한다.
        
        if hasattr(self, 'db'):
            self.db.finish(self.db_tag)    
        
    def init_config_from_dict_config_file(self):
        
        #
        # 데이터베이스 관련 정보
        
        self.db_host = config.monitor_config.seocho_db_info['db_host']
        self.db_id   = config.monitor_config.seocho_db_info['id']
        self.db_pw   = config.monitor_config.seocho_db_info['pw']
        self.db_name = config.monitor_config.seocho_db_info['db']
        self.db_port = config.monitor_config.seocho_db_info['port']
        self.db_tag  = config.monitor_config.seocho_db_info['tag']
        
        log.debug("#"*80)
        log.debug("# db_host    : %s" % self.db_host)
        log.debug("# db_id      : %s" % self.db_id)
        log.debug("# db_pw      : %s" % self.db_pw)
        log.debug("# db_name    : %s" % self.db_name)
        log.debug("# db_port    : %s" % self.db_port)
                
        #
        # 감시대상 스위치 정보
        """    
            * SNMP 활성화 및 SNMP Community 생성
            - AGGR SW와  TOR SW에 동일하게 SNMP 설정
            - SNMP community
               1) public (read-only)
               2) private (read-write)
            
            AGGR-SWITCH(config)#snmp-server community public ro
            AGGR-SWITCH(config)#snmp-server community private rw
            AGGR-SWITCH(config)#end
            AGGR-SWITCH#wr m
            Copy completed successfully.
            
            * 설정 확인
            snmpwalk -v2c -c public -On 221.151.188.9
            
            root@controller:~# snmpwalk -v2c -c public 221.151.188.9 iso.3.6.1.2.1.1.5.0 iso.3.6.1.2.1.1.5.0 = STRING: "AGGR-SWITCH"
            
            root@controller:~# snmpwalk -v2c -c public 221.151.188.19 iso.3.6.1.2.1.1.5.0 iso.3.6.1.2.1.1.5.0 = STRING: "TOR-SWITCH"            
        """
    
        # 감시대상 스위치 리스트
        self.switch_list = config.monitor_config.seocho_monitor['switch_list']
        
        log.debug("#"*80)
        log.debug("# switch_list    : %s" % self.switch_list)
        
        # 감시대상 스위치
        self.aggr_sw = config.monitor_config.seocho_monitor['aggr_sw']
        self.tor_sw  = config.monitor_config.seocho_monitor['tor_sw']
        
        log.debug("#"*80)
        log.debug("# aggr_sw : %s" % self.aggr_sw)
        log.debug("# tor_sw  : %s" % self.tor_sw)
        
    def database_connect(self):
        
        self.db     = myRSQL()
        self.db.connect(self.db_tag, \
                        self.db_host, self.db_id, self.db_pw, self.db_name, int(self.db_port) )
    
    def run(self):
        
        for switch in self.switch_list:
            sw = getattr(self, switch)
            ip = sw['ip']            
            
            SNMP_Port_Status(switch, ip, 'public').run()
            #SNMP_Port_DB(switch, ip, 'public').run()
            #SNMP_Port_Traffic(switch, ip, 'public').run()
            
            
if __name__ == "__main__":

    SwitchMonitor().run()
    
