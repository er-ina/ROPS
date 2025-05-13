#!/bin/bash

include(gendir/script.m4)

bin=$1
tests=$2

for ((i = 0; i < fsm_num_stati; i++))
do
	(
	while read a r
	do
		echo $i $a $i
	done
	) < gendir/ingressi > ${tests}/$i
	${bin}/test ${tests}/$i > ${tests}/out_$i
done
