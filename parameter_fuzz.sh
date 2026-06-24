#!/bin/bash

read -p "Enter the site: " site
read -p "Enter Starting Value: "  start
read -p "Enter Ending Value: " end

for ((i=start;i<=end;i++)); do 
# Example http://localhost.ctf/user?file=
        url="${site}${i}"
        echo "Requesting ${url}"
        status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
        echo " HTTP status:  $status"
done
