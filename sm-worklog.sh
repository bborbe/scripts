#!/bin/bash

function join_by { local IFS="$1"; shift; echo "$*"; }

list=$(find ~/Documents/workspaces/gartentechnik/gartentechnik ~/Documents/workspaces/kubernetes/manifests ~/Documents/workspaces/sm-* ~/Documents/workspaces/python/* $GO/src/bitbucket.apps.seibert-media.net $GO/src/github.com/bborbe $GO/src/github.com/seibert-media $GO/src/bitbucket.org/bborbe -name .git -type d -prune -exec dirname {} \;)

worklog -v=0 -logtostderr -days 20 -author "Benjamin Borbe" -dir $(join_by , $list) | sort | uniq
