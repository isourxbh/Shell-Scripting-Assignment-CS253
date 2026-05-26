#!/bin/bash

# Check if all three arguments are provided
if [ $# -ne 3 ]; then
    echo "Usage: bash detect.sh <clean_log.csv> <whitelist.txt> <output.sh>"
    exit 1
fi

# Assign the input arguments
logfile="$1"
whitelist="$2"
output="$3"

# Clear the output file before writing
> "$output"

# Use awk to:
# - Filter all the "Failed password" entries
# - Extract  the IP address
# - Count total number of failures per IP
awk -F',' '
/Failed password/ {
    for(i=1;i<=NF;i++){
        if($i ~ /ip=/){
            split($i,a,"=");
            ip=a[2];
            gsub(/ /,"",ip);   # removing the spaces
            count[ip]++;
        }
    }
}
END {
    # Print only those IPs with more than 10 failures
    for(ip in count){
        if(count[ip] > 10){
            print ip, count[ip];
        }
    }
}' "$logfile" | while read ip cnt
do
    found=0   # use of the flag to check if the  IP is in whitelist

    # Manually check if IP is in whitelist (loop constraint)
    while read wip
    do
        wip="${wip%$'\r'}"
        if [ "$ip" = "$wip" ]; then
            found=1
            break
        fi
    done < "$whitelist"

    # If the IP is NOT found in whitelist, generate the firewall rule
    if [ $found -eq 0 ]; then
        echo "iptables -A INPUT -s $ip -j DROP # Blocked after $cnt failed attempts" >> "$output"
    fi

done