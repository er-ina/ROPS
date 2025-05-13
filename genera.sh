#!/bin/sh

FILE=$1

OUTDIR=`jq -r '.outdir' ${FILE}` SPECS=${FILE} make
