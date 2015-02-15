#!/usr/bin/env python
# -*- coding: utf-8 -*-
''' 
Purpose   : Intercepting messages that pass around neutron-services directly from rabbitmq
Author    : Namgon Kim
Date      : Oct. 22, 2014
'''

from kombu import Connection
from kombu.mixins import ConsumerMixin
from kombu.log import get_logger
from kombu import Queue, Exchange

import sys
import json
import collections
from pprint import pprint

logger = get_logger(__name__)

class StringUtil:
 
     def __init__(self):
         self.INFO = '\033[94m'
         self.DBG = '\033[93m'
         self.WARN = '\033[92m'
         self.ERR = '\033[91m'
 
         self.ENDC = '\033[0m'
 
     def highlight(self, msg, type = "" ):
         if type == "info":
             return self.INFO + "%s" % msg + self.ENDC
         elif type == "debug":
             return self.DBG + "%s" % msg + self.ENDC
         elif type == "warn":
             return self.WARN + "%s" % msg + self.ENDC
         elif type == "error":
             return self.ERR + "%s" % msg + self.ENDC
         else:
             return "%s" % msg

class Worker(ConsumerMixin):
    
    def __init__(self, connection, exchange_name, queue_name):
        self.connection = connection
        #self.exchange = Exchange('neutron', 'topic', durable=False)
        self.exchange = Exchange(exchange_name, 'topic', durable=False)
        #self.task_queue = Queue('q-plugin', self.exchange, durable=False)
        #self.task_queue = Queue('notifications.info', self.exchange, durable=False)
        self.task_queue = Queue(queue_name, self.exchange, durable=False)


    def get_consumers(self, Consumer, channel):
        return [Consumer(queues=[self.task_queue],
                         accept=['json'],
                         callbacks=[self.process_task])]

    def process_task(self, body, message):
        self.manual_print(body)
        #self.print_body(body)
        message.ack()        

    def recursive_print(self, key, body):
        # TODO: print recursively if data type is dict
        data = body[key]
        if type(data) is dict:
            print ("\t      --+ %-15s " % (key))
            for key1 in data.keys():
                self.recursive_print(key1, data[key])                
        else:
            print ("\t      --- %-15s= %s" % (key, data))    

   
    def manual_print(self, body):
        oslo_msg = body['oslo.message']
        oslo_msg = json.loads(oslo_msg)

        # ignore "report_state" method
        method = oslo_msg['method']
        if method in { "report_state" }:
            return

        # Clear screen
        sys.stderr.write("\x1b[2J\x1b[H")
        print("\n*** RECEIVED MESSAGE= \n")
        #for key in sorted(oslo_msg.keys(), reverse=True):
        
        key = "oslo.version"
        print("\t%-25s= %s" % (key, body[key]))
        
        for key in sorted(oslo_msg.keys(), reverse=True):
            if key in ("method", "args"):
                continue
            print("\t%-25s= %s" % (key, oslo_msg[key]))

        print("")

        #print("\t%-25s= %s" % ("method", StringUtil().highlight(method, "error")))

        key_list = { "method", "args" }
        for key in sorted(key_list, reverse=True):
            if key in oslo_msg.keys():
                data = oslo_msg[key]
                if type(data) is dict: 
                    print ("\t%-25s= " % (key)) # key
                    for key1 in data.keys():
                        data1 = data[key1]
                        if type(data1) is dict:
                            print ("\t  --+ %-15s" % (key1)) # key1
                            for key2 in data1.keys():
                                data2 = data1[key2]
                                if type(data2) is dict:
                                    print ("\t    --+ %-15s " % (key2)) # key2
                                    for key3 in data2.keys():
                                        data3 = data2[key3]
                                        if type(data3) is dict:
                                            print ("\t      --+ %-15s " % (key3)) # key2
                                            for key4 in data3.keys():
                                                data4 = data3[key4]
                                                if type(data4) is dict:
                                                    print ("\t        --+ %-15s " % (key4)) # key2
                                                    for key5 in data4.keys():
                                                        print("\t          --- %-15s= %s" % (key5, data4[key5])) # key5
                                                else:
                                                    print("\t        --- %-30s= %s" % (key4, data3[key4])) # key3
                                        else:
                                            print ("\t      --- %-15s= %s" % (key3, data2[key3]))                                        
                                else:
                                    print ("\t    --- %-15s= %s" % (key2, data1[key2]))
                        else:
                            print ("\t  --- %-15s= %s" % (key1, data1)) # key1
                else:
                    # method
                    print("\t%-25s= %s" % (key, oslo_msg[key])) 


"""
    def manual_print(self, body):
        oslo_msg = body['oslo.message']
        oslo_msg = json.loads(oslo_msg)

        # ignore "report_state" method
        method = oslo_msg['method']
        if method in { "report_state" }:
            return

        # Clear screen
        sys.stderr.write("\x1b[2J\x1b[H")
        print("\n*** RECEIVED MESSAGE= \n")

        key = "oslo.version"
        print("\t%-25s= %s" % (key, body[key]))

        for key in sorted(oslo_msg.keys(), reverse=True):
            if key in ("method", "args"):
                continue
            print("\t%-25s= %s" % (key, oslo_msg[key]))

        print("")

        key_list = { "method", "args" }
        for key in sorted(key_list, reverse=True):
            if key in oslo_msg.keys():
                self.recursive_print(key, oslo_msg)

"""

if __name__ == '__main__':
    from kombu import Connection
    from kombu.utils.debug import setup_logging
    # setup root logger
    setup_logging(loglevel='DEBUG', loggers=[''])

    with Connection('amqp://guest:guest@10.0.0.101:5672/%2f') as conn:
        try:
            exchange = sys.argv[1]
            queue = sys.argv[2]
            print(conn)
            worker = Worker(conn, exchange, queue)
            worker.run()
        except KeyboardInterrupt:
            print('bye bye')
