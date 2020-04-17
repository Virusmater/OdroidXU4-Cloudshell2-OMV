#!/bin/bash
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

temp_start_fan=55 #in celsius. adjust it for your own preference

cpu_temp=$(($(</sys/class/thermal/thermal_zone0/temp) / 1000))

echo "cpu temp = " $cpu_temp "C";
echo "start fan temp = " $temp_start_fan "C";


if [ $cpu_temp \> $temp_start_fan ];
then
    echo "starting fan";
    i2cset -y 1 0x60 0x05 0x00; #start fan
else
    echo "stopping fan";
    i2cset -y 1 0x60 0x05 0x05; #stop fan
fi;
