#!/bin/bash

let "bin=2#1111"

echo $bin

if (( $bin & 2#0001 )); then
	echo "Green"
fi

if (( $bin & 2#0010 )); then
	echo "Orange"
fi

if (( $bin & 2#0100 )); then
	echo "RED"
fi

if (( $bin & 2#1000 )); then
	echo "TEST"
fi
