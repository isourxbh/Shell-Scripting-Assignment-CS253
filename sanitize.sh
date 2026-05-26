#!/bin/bash

# Check if exactly one argument (auth.log) is provided o not
if [ $# -ne 1 ]; then
    echo "Usage: bash sanitize.sh <auth.log>"
    exit 1
fi

# Now, store the input filename
input="$1"

# To clean the log , we use the sed command here:
# First: Remove lines containing [CORRUPT-DATA]
# Second: Replace occurences of user=root and user=admin with user=SYS_ADMIN
# Third: Replace all the pipes '|' with commas ','
# Finally use tr to remove Windows carriage return characters (\r)
sed -e '/\[CORRUPT-DATA\]/d' \
    -e 's/user=root/user=SYS_ADMIN/g' \
    -e 's/user=admin/user=SYS_ADMIN/g' \
    -e 's/|/,/g' \
    "$input" | tr -d '\r' > clean_log.csv

# The Output of this script sanitize.sh is now saved in clean_log.csv