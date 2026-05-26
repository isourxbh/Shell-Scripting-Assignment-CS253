#!/bin/bash

# Check if one argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: bash timeline.sh <clean_log.csv>"
    exit 1
fi

file="$1"

# Use the command awk to:
# - Filter all the failed login attempts
# - Extract hour from timestamp
# - Count the number of attempts per hour
awk -F',' '
/Failed password/ {

    # Extract timestamp (from the first column)
    split($1, t, " ");
    time=t[length(t)];

    # Extract hour(HH) from HH:MM:SS
    split(time, h, ":");
    hour=h[1];

    cnt[hour]++;
}
END {
    # Now loop through all the 24 hours (00–23)
    for(i=0;i<24;i++){
        hr=sprintf("%02d", i);   # for conversion into 2 digits format
        if(cnt[hr])
            printf "Hour %s: %d failed attempts\n", hr, cnt[hr];
    }
}' "$file"