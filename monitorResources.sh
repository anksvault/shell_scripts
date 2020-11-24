#!/bin/bash
#-----------------------------------------------------------#
##                                                         ##
## Author: Ankit Vashistha                                 ##
## Script: monitorResources v1.0                           ##
##                                                         ##
#-----------------------------------------------------------#

# Temp File
TMP_FILE="/tmp/diskCheckOUT"

## Define Thresholds
cpu_warn='85'   # CPU
mem_warn='80'  # Mem Idle Threshold
disk_warn='75'  # Disk Usage Threshold


## Check CPU Utilization
item_cpu () {
    cpu_idle=`top -b -n 1 | grep Cpu | awk '{print $8}'|cut -f 1 -d "."`
    cpu_use=`expr 100 - $cpu_idle`
    if [ $cpu_use -gt $cpu_warn ]
    then
        echo "$1:CPU_Warning:$cpu_use"
    else
        echo "$1:CPU_OK:$cpu_use"
    fi
}


# Check Memory Utilization in MBs.
item_mem () {
    mem_free=`free -m | grep "Mem" | awk '{print $4+$6}'`
    if [ $mem_free -lt $mem_warn  ]
    then
        echo "$1:MEM_Warning:$mem_free"
    else
        echo "$1:MEM_OK:$mem_free"
    fi
}


# Check Disk Utilization
item_disk () {
    df -P | grep /dev | grep -v -E '(tmp|boot)' | awk '{print $1 ":" $5}' | cut -f 1 -d "%" >> $TMP_FILE
    while IFS=":" read MOUNT COUNT
    do
        if [ $COUNT -gt $disk_warn ]
        then
            echo "$1:DISK_Warning:$MOUNT:$COUNT"
        else
            echo "$1:DISK_OK:$MOUNT:$COUNT"
        fi
    done<$TMP_FILE
}


## Main
CT=`date +'%d-%m-%Y %H:%M:%S %Z'`
item_cpu "$CT"
item_mem "$CT"
item_disk "$CT"

## Remove temp file
rm -f $TMP_FILE
