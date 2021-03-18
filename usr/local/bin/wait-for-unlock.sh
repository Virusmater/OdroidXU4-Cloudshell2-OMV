#!/bin/sh
# wait-for-unlock.sh

while true; do 
  if df | grep -q '/dev/mapper/sda-crypt';
  then
    echo "unlocked, exiting..."
    exit
  else
    echo "still locked, wait for 10 seconds and try again"
    sleep 10
fi
done
