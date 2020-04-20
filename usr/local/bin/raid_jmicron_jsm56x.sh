#!/bin/bash
# Mainly got from https://gist.github.com/peci1/9ca0cd57d0ecc2c3a6cd4446207d213d
if [ $# -eq 0 ]
  then
    echo "No arguments supplied. Use -s --status or -t --temperature)"
    exit
fi

status (){
        STATUS="$(echo -e "SR C0\nEX\n" | raidmgr_static)"
        RAID_STATUS="$(echo "${STATUS}" | grep RaidStatus | awk '{ print $NF }')"
        echo ${RAID_STATUS}
}


temperature (){
        DISK_TEMPS="$(echo -e "SM C0 D0\nSM C0 D1\nEX\n" | "raidmgr_static" | grep "^ 194" | awk '{print $2}' | tr "\n" ", " | head -c-1)"
        echo ${DISK_TEMPS}
}


while [ "$1" != "" ]; do
    case $1 in
        -s | --status )         shift
                                status
                                exit
                                ;;
        -t | --temperature )    shift
                                temperature
                                exit
                                ;;
        * )                     exit 1
    esac
    shift
done
