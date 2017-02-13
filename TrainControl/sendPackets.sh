#!/bin/bash

while [ true ]
do
echo "11000" | nc -w0 -u 192.168.1.147 8888
sleep 0.2
#print milliseconds
echo $(($(date +%s%N)/1000000))
done
