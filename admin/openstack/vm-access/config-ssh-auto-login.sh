#!/bin/bash

source "./vm-access.cfg"

RET=`ssh $N_NODE "$DIR_BIN/netns.sh ssh-copy-id $VM_ADM@$VM_IP"`

echo $RET

#ERR_NO_ID="/usr/bin/ssh-copy-id: ERROR: No identities found"

