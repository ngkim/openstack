#!/bin/bash

source "./sflow.cfg"

ovs-vsctl -- --id=@sflow create sflow agent=${AGENT}  \
	target=\"${COLLECTOR_IP}:${COLLECTOR_PORT}\" \
	header=${HEADER} \
	sampling=${SAMPLING} \
	polling=${POLLING} \
	-- set bridge $BRIDGE sflow=@sflow
