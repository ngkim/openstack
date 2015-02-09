#!/bin/bash

VMID=instance-00000127

pCPU[0]="0"
pCPU[1]="16"
pCPU[2]="1"
pCPU[3]="17"
pCPU[4]="2"
pCPU[5]="18"
pCPU[6]="3"
pCPU[7]="19"
pCPU[8]="4"
pCPU[9]="20"
pCPU[10]="5"
pCPU[11]="21"
pCPU[12]="6"
pCPU[13]="22"
pCPU[14]="7"
pCPU[15]="23"

vcpupin() {
	VMID=$1
	vCPU=$2
	pCPU=$3

	echo "$VMID: pin $vCPU with $pCPU"
	virsh vcpupin $VMID $vCPU $pCPU
}

vm_vcpupin() {
	VMID=$1
	if [ -z $2 ]; then
		idx=0;
	else
		idx=$2
	fi

	for i in `seq 0 15`; do
		vcpupin $VMID $i ${pCPU[$idx]}
		idx=`expr $idx + 1`
	done
	
	virsh vcpuinfo $VMID
}

vm_vcpupin_core_siblings() {
	VMID=$1
	CORES=$2

	for i in `seq 0 15`; do
		vcpupin $VMID $i $CORES
	done
}

#vm_vcpupin $VMID
vm_vcpupin_core_siblings $VMID 0-7,16-23
#vm_vcpupin_core_siblings $VMID 0-31
