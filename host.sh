#!/bin/bash

###### Example: ./host.sh 10.10.10.10 ######

exiting() {
     echo
     echo "[!] Exiting....."
     exit 130 	
}

trap exiting SIGINT

ip="$1"

host="${ip%.*}"

echo "[*]Scanning $host.0/24"

for value in $(seq 1 254); do
	if timeout 1 ping -c 1 "$host.$value" &> /dev/null;then
	echo "[*]Host is up: $host.$value"
	fi
done 
