import socket
import json
import collections

OVSDB_IP = '211.224.204.147'
OVSDB_PORT = 6632

def main():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((OVSDB_IP, OVSDB_PORT))
    
    #list_dbs_query =  {"method":"list_tables", "params":[], "id": 0}
    show_query =  {"method":"monitor","params":["Open_vSwitch","null",{
                        "Port":{
                            "columns":["interfaces","name","tag","trunks"]
                        },"Controller":{
                            "columns":["is_connected","target"]
                        },"Interface":{
                            "columns":["name","options","type"]
                        },"Open_vSwitch":{
                            "columns":["bridges","cur_cfg","manager_options","ovs_version"]
                        },"Manager":{
                            "columns":["is_connected","target"]
                        },"Bridge":{
                            "columns":["controller","fail_mode","name","ports"]
                        }
                    }], 
                   "id": 0}
    
    list_ports_query = { "method":"monitor", "params":["Open_vSwitch","null",{
                            "Port":{
                                #"columns":["fake_bridge","interfaces","name","tag"]
                                "columns":["name", "tag"]
                                #"columns":[]
                            },"Controller":{
                                "columns":[]
                            },"Interface":{
                                "columns":["name","admin_state"]
                            },"Open_vSwitch":{
                                #"columns":["bridges","cur_cfg"]
                                "columns":[]
                            },"Bridge":{
                                #"columns":["controller","fail_mode","name","ports"]
                                #"columns":["name", "ports"]
                                #"columns":[]
                            }}], "id": 0 }

    s.send(json.dumps(list_ports_query))
    
    chunks = []
    lc = rc = 0
    read_on = True
    while read_on:
        try: 
            response = s.recv(4096)
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
    
    interfaces = {}
    for keys in result:
        for key1 in result[keys]:
            for key2 in result[keys][key1]:
                #if "name" in result[keys][key1][key2].keys():
                if "admin_state" in result[keys][key1][key2].keys() and "name" in result[keys][key1][key2].keys():
                    name = result[keys][key1][key2]["name"]
                    state = result[keys][key1][key2]["admin_state"] 
                #for key3 in result[keys][key1][key2]:
                #    name = result[keys][key1][key2]["name"]
                #    tag = result[keys][key1][key2]["tag"]
                    
                #    if type(tag) is list:
                #        continue
                    """
                    if "qvo" in name:
                        name = name.replace("qvo", "")
                    if "tap" in name:
                        name = name.replace("tap", "")
                    """
                #    interfaces[name] = tag
                    #intf = { name:tag }
                    #group = name[3:]
                    #interfaces[group] = intf
                                        
                    #print "[%s] %s [%s] %-15s %s" % (keys, key1, key2, name, tag)
                    #print "%-15s %s" % (name, tag)
                    #if key3 == "tag":
                    
                    print "[%s] %s [%s] %s %s" % (keys, key1, key2, name, state)
                    #for port in ports.pop():
                    #    print "\t%s" % port.pop()                    
    """
    for key in sorted(interfaces.values()):
        print "key= %s value= %s" % (key, interfaces[key])
    """
    #for group in sorted(interfaces.keys()):
    #    for name in group.keys():
    #        print "name= %s tag= %s" % (name, interfaces[group][name])
        
    
                        
    
    #print json.dumps(response, indent=4, sort_keys=True)
    

if __name__ == "__main__":
    main()
