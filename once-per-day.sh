#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

touch /tmp/once-per-day-timestamp

date +%F |                                    ## Generate timestamp (could be a better date-spec)
   tee /tmp/once-per-day-timestamp.tmp |      ## Save a copy for later usage
   cmp -s - /tmp/once-per-day-timestamp ||       ## Fail if date-spec changed
   {  
      ## In that case, update timestamp
      mv /tmp/once-per-day-timestamp.tmp /tmp/once-per-day-timestamp &&

      ## And only if that succeeds, run your code
      echo "Once a day" ;
    }
