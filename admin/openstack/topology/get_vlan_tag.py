# -*- coding: utf-8 -*-
import sys, socket
import json
import collections

OVSDB_IP = '127.0.0.1'
OVSDB_PORT = 6632

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
                            "Port":{
                                #"columns":["fake_bridge","interfaces","name","tag"]
                                "columns":["name", "tag"]
                                #"columns":[]
                            }}], "id": 0 }

    result = send_query(s, list_ports_query)

    interfaces = {}
    for keys in result:
        for key1 in result[keys]:
            for key2 in result[keys][key1]:
                if "tag" in result[keys][key1][key2].keys() and "name" in result[keys][key1][key2].keys():
                    name = result[keys][key1][key2]["name"]
                    tag = result[keys][key1][key2]["tag"] 
                    
                    if type(tag) is list:
                        continue
                    #print "%s %s" % (name, tag)
                    interfaces[name] = tag
                                        
    
    #for key in sorted(interfaces.keys()):
    #    print "key= %s value= %s" % (key, interfaces[key])
    if len(sys.argv) < 2: 
        print "인터페이스 이름을 입력하세요."
        print "예) %s tap12341-56" % sys.argv[0]
    
    name = sys.argv[1]
    if name in interfaces.keys():
        print interfaces[name]
    else:
        #print "존재하지 않는 인터페이스 입니다.(%s)" % name
        print -1
    

if __name__ == "__main__":
    main()
