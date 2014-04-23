#!/bin/sh

for i in `virsh list --all|grep 'shut off'|grep -v windows| awk '{ print $2 }'|grep -v Name`; do
	echo $i
	virsh start $i
done
