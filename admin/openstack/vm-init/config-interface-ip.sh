#!/bin/bash

source "./vm-access.cfg"

echo  "${VM_IP}.GREEN: config interface IP= $DEV_GREEN_IP"
ifconfig $DEV_GREEN $DEV_GREEN_IP up

echo "${VM_IP}.GREEN: check interface= $DEV_GREEN"
ifconfig $DEV_GREEN

echo "${VM_IP}.ORANGE: config interface IP= $DEV_ORANGE_IP"
ifconfig $DEV_ORANGE $DEV_ORANGE_IP up

echo "${VM_IP}.ORANGE: check interface= $DEV_ORANGE"
ifconfig $DEV_ORANGE


