#!/bin/bash

source "./sflow.cfg"

ovs-vsctl -- clear Bridge $BRIDGE sflow

