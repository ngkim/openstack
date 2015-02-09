#!/bin/bash

source "$MNG_ROOT/include/print.sh"
source "$MNG_ROOT/include/process.sh"

MNT_DIR=/mnt/ubuntu

print_info "VM-IMAGE" "Unmount $MNT_DIR"
umount $MNT_DIR

print_info "VM-IMAGE" "Kill qemu-nbd process"
kill_local_processes qemu-nbd
sleep 5

print_info "VM-IMAGE" "Remove nbd module"
rmmod nbd
