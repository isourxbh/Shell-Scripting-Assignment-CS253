#!/bin/bash

# Check if one argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: bash report.sh <clean_log.csv>"
    exit 1
fi

file="$1"

# Printing the header
echo "Target Port Analysis"
echo "-------------------"

# Use the command awk to:
# --> Filter all the failed login attempts
# --> Extract the port number
# --> Count the number of attempts per port
awk -F',' '
/Failed password/ {
    for(i=1;i<=NF;i++){
        if($i ~ /port=/){
            split($i,a,"=");
            port=a[2];
            gsub(/ /,"",port);   # removing the spaces
            count[port]++;
        }
    }
}
END {
    for(p in count){
        printf "Port %s : %d attempts\n", p, count[p];
    }
}' "$file" | sort -rn -k4   # sort output by number of attempts descending