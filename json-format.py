#!/usr/bin/env python

import json
import sys

with open(sys.argv[1], 'r') as f:
    json_data = json.loads(f.read())

with open(sys.argv[1], 'w') as f:   
   data = json.dumps(json_data, indent=4, sort_keys=True)
   f.write(data)

# find . -name "*.json" -exec python -c 'import json;import sys;f = open(sys.argv[1], "r");json_data = json.loads(f.read());f.close();f = open(sys.argv[1], "w");f.write(json.dumps(json_data, indent=4, sort_keys=True));f.close()' "{}" \;
