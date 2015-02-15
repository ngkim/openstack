#!/usr/bin/env python

''' purpose : Intercepting messages that pass around nova-services directly from rabbitmq
author: Prosunjit Biswas
Date: Nov 8, 2013
'''

import pika
import sys

global messageno
messageno = 0

parameters = pika.URLParameters('amqp://guest:guest@10.0.0.101:5672/%2f')
connection = pika.BlockingConnection(parameters)

exchange_name="neutron"
queue_name = "compute.havana"
binding_key = "#"

channel = connection.channel()
channel.exchange_declare(exchange = exchange_name, type='topic')

result = channel.queue_declare(exclusive=True)
channel.queue_bind(exchange=exchange_name, queue=queue_name, routing_key=binding_key)

print ' [*] Waiting for logs. To exit press CTRL+C'

def callback(ch, method, properties, body):
    global messageno
    messageno = messageno + 1
    print "\n\n"
    print ("----------------{}th message -----------------\n".format(messageno))
    print " [x] %r:%r" % (method.routing_key, body,)
    
#Fair dispatch: Tell rabbitmq not give a worker more than one messages at a time  
channel.basic_qos(prefetch_count=1)      

# 4. Subscribe the callback function to a queue.  
#Tell RabbitMQ that this particular callback function should receive messages from our hello queue. 
channel.basic_consume(callback,
                      queue_name,
                      no_ack=False)# turn on the (ack)onwledgment, default is False  

 # 5. Enter a never-ending loop that waits for data and runs callbacks whenever necessary.  
channel.start_consuming()