#!/bin/bash
for cluster in hetzner-1 fire nuke sun netcup; do
	kubectl --context ${cluster} version|grep 'Server Version'|awk "{print \"${cluster}: \" \$5}"
done 
