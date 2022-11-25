#!/bin/bash

#Setup Variables

#System Architecture
ARCH=$(uname -a)

#CPU (VCPU = CPU * THREADS * CORES)
PCPU=$(lscpu | grep "CPU(s)" | sed -n 1p | tr -d -c 0-9)
THREADS=$(lscpu | grep Thread | tr -d -c 0-9)
SOCKETS=$(lscpu | grep Socket | tr -d -c 0-9)
VCPU=$((PCPU * THREADS * SOCKETS))
CPU_LOAD=$(mpstat | grep all | awk '{CPU_TOT = $4 + $5 + $6 + $7 + $8 + $9 + $10 + $11 + $12} END {printf("%.2f%%"), CPU_TOT}')

#RAM
MEM_USED=$(free -m | awk '$1 == "Mem:" {print $3}')
MEM_TOT=$(free -m | awk '$1 == "Mem:" {print $2}')
MEM_PCNT=$(free | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')

#DISK
DISK_USED=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{USE_TOT += $3} END {print USE_TOT}')
DISK_TOT=$(df -Bg | grep '^/dev/' | grep -v '/boot$' | awk '{TOT += $2} END {print TOT}')
DISK_PCNT=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{USE_TOT += $3} {TOT += $2} END {printf("%d"), USE_TOT/TOT*100}')

#OTHER
LAST_BOOT=$(who -b | awk '$1 == "system" {print $3 " " $4}')
LVM_USE=$(lsblk | grep "lvm" | wc -l)
LVM_STAT=$(if [ $LVM_USE -eq 0 ]; then echo no; else echo yes; fi)
TCP_CNT=$(netstat -natp | grep -v "tcp6" | grep "tcp" | wc -l)
USER_CNT=$(users | wc -w)
IP_ADR=$(hostname -I)
MAC_ADR=$(ip link show | awk '$1 == "link/ether" {print $2}')
SUDO_CNT=$(journalctl -q _COMM=sudo | grep COMMAND | wc -l)

wall "	#Architecture: $ARCH
		#CPU Physical: $PCPU
		#vCPU: $VCPU
		#Memory Usage: $MEM_USED/${MEM_TOT}MB ($MEM_PCNT%)
		#Disk Usage: $DISK_USED/${DISK_TOT}Gb ($DISK_PCNT%)
		#CPU Load: $CPU_LOAD
		#Last Boot: $LAST_BOOT
		#LVM Use: $LVM_STAT
		#Connections TCP: $TCP_CNT ESTABLISHED
		#User Log: $USER_CNT
		#Network: IP $IP_ADR ($MAC_ADR)
		#Sudo: $SUDO_CNT cmd"
