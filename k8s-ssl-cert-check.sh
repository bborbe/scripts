#!/bin/bash

# List of kubectl contexts
contexts=("hell" "quant")

# --- Configuration ---
# Set the warning period in days
WARNING_DAYS=30
# ---------------------

# Get current time as a timestamp
now_ts=$(date +%s)

# Calculate the timestamp for the warning threshold
warning_ts=$((now_ts + WARNING_DAYS * 86400)) # 86400 seconds in a day

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

                # Check the status in order: Expired, Expires Soon, or Valid
                if [ "$expiry_ts" -le "$now_ts" ]; then
                    echo "[$ctx] ❌ Domain $domain is invalid (expired: $expiry_iso)"
                elif [ "$expiry_ts" -le "$warning_ts" ]; then
                    echo "[$ctx] ⚠️  Domain $domain expires soon (expires: $expiry_iso)"
                else
                    echo "[$ctx] ✅ Domain $domain is valid (expires: $expiry_iso)"
                fi
            else
                echo "[$ctx] ❌ Domain $domain is invalid (could not retrieve certificate)"
            fi
        done
    done
done
