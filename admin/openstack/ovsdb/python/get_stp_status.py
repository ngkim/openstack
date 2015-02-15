# -*- coding: utf-8 -*-
import sys, socket
import json
import collections
import traceback
from neutron.openstack.common import log as logging

LOG = logging.getLogger(__name__)

OVSDB_IP = '211.224.204.147'
OVSDB_PORT = 6632

def tracefunc(frame, event, arg, indent=[0]):
      if event == "call":
          indent[0] += 2
          msg = "%s>call function %s" % ("-" * indent[0], frame.f_code.co_name)
          print msg
          #LOG.debug(_(msg))          
      elif event == "return":
          msg = "<%sexit function %s" % ("-" * indent[0], frame.f_code.co_name)
          print msg
          #LOG.debug(_(msg))
          indent[0] -= 2
      return tracefunc

#sys.settrace(tracefunc)

def send_query(socket, query):
    socket.send(json.dumps(query))
    
    chunks = []
    lc = rc = 0
    read_on = True
    while read_on:
        try: 
            response = socket.recv(4096)
            if response:
                response = response.decode('utf8')
                message_mark = 0
                for i, c in enumerate(response):
                    #todo fix the curlies in quotes
                    if c == '{':
                        lc += 1
                    elif c == '}':
                        rc += 1
    
                    if rc > lc:
                        raise Exception("json string not valid")
    
                    elif lc == rc and lc is not 0:
                        chunks.append(response[message_mark:i + 1])
                        message = "".join(chunks)
                        #print "message= %s" % message
                        read_on = False
                        lc = rc = 0
                        message_mark = i + 1
                        chunks = []
    
                chunks.append(response[message_mark:])
        except (KeyboardInterrupt, SystemExit):
            read_on = False   
    
    json_m = json.loads(message)
    result = json_m.get('result', None)
    
    return result             
            
def main():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((OVSDB_IP, OVSDB_PORT))
    
    list_ports_query = { "method":"monitor", "params":["Open_vSwitch","null",{
                            "Bridge":{
                                #"columns":["fake_bridge","interfaces","name","tag"]
                                "columns":["name","stp_enable"]
                                #"columns":[]
                            }}], "id": 0 }

    result = send_query(s, list_ports_query)

    interfaces = {}
    for keys in result:
        for key1 in result[keys]:
            for key2 in result[keys][key1]:
                if "name" in result[keys][key1][key2].keys() and "stp_enable" in result[keys][key1][key2].keys():
                    name = result[keys][key1][key2]["name"]
                    stp = result[keys][key1][key2]["stp_enable"] 
                    
                    #print "%s %s" % (name, tag)
                    interfaces[name] = stp
                                        
    
    for name in interfaces.keys():
        print "name= %-10s stp= %-5s" % (name, interfaces[name])
    

if __name__ == "__main__":
    main()
