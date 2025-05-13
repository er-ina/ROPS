#!/bin/sh

for i in machines/*.json; do
	./genera.sh $i
done
