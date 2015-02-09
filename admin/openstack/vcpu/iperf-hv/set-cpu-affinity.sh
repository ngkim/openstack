#!/bin/bash 


set_cpu_affinity() {
	IRQ=$1
	CPU=$2

	echo $CPU > /proc/irq/$IRQ/smp_affinity
	get_cpu_affinity $IRQ
}

get_cpu_affinity() {
	IRQ=$1

	cat /proc/irq/$IRQ/smp_affinity
}

set_cpu_affinity 98  00000001
set_cpu_affinity 99  00000002
set_cpu_affinity 100 00000004
set_cpu_affinity 101 00000008

set_cpu_affinity 102 00000010
set_cpu_affinity 103 00000020
set_cpu_affinity 104 00000040
set_cpu_affinity 105 00000080

set_cpu_affinity 106 00010000
set_cpu_affinity 107 00020000
set_cpu_affinity 108 00040000
set_cpu_affinity 109 00080000

set_cpu_affinity 110 00100000
set_cpu_affinity 111 00200000
set_cpu_affinity 112 00400000
set_cpu_affinity 113 00800000



set_cpu_affinity 114 00000100
set_cpu_affinity 115 00000200
set_cpu_affinity 116 00000400
set_cpu_affinity 117 00000800

set_cpu_affinity 118 00001000
set_cpu_affinity 119 00002000
set_cpu_affinity 120 00004000
set_cpu_affinity 121 00008000

set_cpu_affinity 122 01000000
set_cpu_affinity 123 02000000
set_cpu_affinity 124 04000000
set_cpu_affinity 125 08000000

set_cpu_affinity 126 10000000
set_cpu_affinity 127 20000000
set_cpu_affinity 128 40000000
set_cpu_affinity 129 80000000

