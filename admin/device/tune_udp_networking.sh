#!/bin/bash

ulimit -n 65535

ifconfig p1p1 txqueuelen 10000
ifconfig phy-br-hybrid txqueuelen 10000
ifconfig int-br-hybrid txqueuelen 10000
