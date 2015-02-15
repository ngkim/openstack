#!/bin/bash

DIR_INFO="/tmp/host-info"

mkdir -p $DIR_INFO

echo "1. CPU Info"
cat /proc/cpuinfo > $DIR_INFO/cpu-info

echo "2. Mem Info"
cat /proc/meminfo > $DIR_INFO/mem-info

echo "3. Disk Info"
df -h > $DIR_INFO/disk-info-df
udisks --show-info /dev/sda1 > $DIR_INFO/disk-info-udisks

echo "4. NIC Info"
lshw -c network > $DIR_INFO/nic-info
