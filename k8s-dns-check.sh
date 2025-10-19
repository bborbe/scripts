#!/bin/bash

# List of kubectl contexts
contexts=("hell" "quant")

# Get current time as a timestamp once
now_ts=$(date +%s)

# Loop over each context
for ctx in "${contexts[@]}"; do
    echo "=== Checking cluster context: $ctx ==="

    # Get all ingress hosts for this context
    kubectl --context="$ctx" get ing --all-namespaces -o custom-columns=HOSTS:'.spec.rules[*].host' --no-headers | while read -r line; do
        # Split multiple hosts per ingress line
        for domain in $line; do
            # Try to get the certificate's end date string
            if expiry_str=$(echo | openssl s_client -connect "$domain":443 -servername "$domain" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2); then

                # Convert the date string to ISO format (for printing)
                expiry_iso=$(date -u -d "$expiry_str" +'%Y-%m-%dT%H:%M:%SZ')

                # Convert the date string to a timestamp (for comparison)
                expiry_ts=$(date -d "$expiry_str" +%s)

                if [ "$expiry_ts" -gt "$now_ts" ]; then
                    echo "[$ctx] ✅ Domain $domain is valid (expires: $expiry_iso)"
                else
                    echo "[$ctx] ❌ Domain $domain is invalid (expired: $expiry_iso)"
                fi
            else
                echo "[$ctx] ❌ Domain $domain is invalid (could not retrieve certificate)"
            fi
        done
    done
done
