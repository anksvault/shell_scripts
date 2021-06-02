#!/bin/bash
#-----------------------------------------------------------#
##                                                         ##
## Author: Ankit Vashistha                                 ##
## Script: monitorResources v2.0                           ##
##                                                         ##
#-----------------------------------------------------------#


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
df -h | grep -vE '^Filesystem|tmp|boot' | awk '{ print $5 " " $1 }' | while read MOUNT;
    do
        disk_use=$(echo $MOUNT | awk '{ print $1}' | cut -d'%' -f1  )
        partition=$(echo $MOUNT | awk '{ print $2 }' )
        if [ $disk_use -gt $disk_warn ]; then
            echo "$1:DISK_Warning:$MOUNT:$usep%"
        else
            echo "$1:DISK_OK:$MOUNT:$usep%"
        fi
    done
}


# Check Top Memory Consuming Process
item_top_mem() {
    top_proc=$(ps -eocomm,pmem | egrep -v '(0.0)|(%MEM)'|head -1)
    fmt_top_proc=$(echo $top_proc|sed 's/ /:/g')
    echo "$1:TOP_PROC_BY_MEM:$fmt_top_proc"
}


item_top_cpu() {
    top_proc=$(ps -eocomm,pcpu | egrep -v '(0.0)|(%CPU)'|head -1)
    fmt_top_proc=$(echo $top_proc|sed 's/ /:/g')
    echo "$1:TOP_PROC_BY_CPU:$fmt_top_proc"
}


## Main
CT=`date +'%d-%m-%Y %H:%M:%S %Z'`
item_cpu "$CT"
item_mem "$CT"
item_disk "$CT"
item_top_mem "$CT"
item_top_cpu "$CT"
