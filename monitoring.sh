#!/bin/bash

Architecture=$(uname -a)

PhysicalCpu=$(lscpu | awk '$1 == "CPU(s):" {print $2}')
VirtualCpu=$(cat /proc/cpuinfo | grep "^processor" | wc -l)

MemoryTotal=$(free -m | awk '$1 == "Mem:" {print $2}')
MemoryUsed=$(free -m | awk '$1 == "Mem:" {print $3}')
MemoryPercent=$(free | awk '$1 == "Mem:" {printf("%.2f"), ($3/$2)*100}')

DiskTotal=$(df -Bg | grep '^/dev/' | grep -v '/boot$' | awk '{dt += $2} END {print dt}')
DiskUsed=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{du += $3} END {print du}')
DiskPercent=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{du += $3} {dt+= $2} END {print(int((du/dt)*100))}')

CpuLoad=$(vmstat 1 2 | tail -1 | awk '{printf "%.1f\n", 100 - $15}')
LastBoot=$(who -b | awk '$1 == "system" {print $3 " " $4}')
LvmTotal=$(lsblk | grep "lvm" | wc -l)
LvmUsage=$(if [ $LvmTotal -eq 0 ]; then echo no; else echo yes; fi)
TcpConnections=$(ss -t | grep -E '^(ESTAB)' | wc -l)
UserLog=$(who | uniq | wc -l)
NetworkIp=$(hostname -I)
NetworkMac=$(ip link | awk '$1 == "link/ether" {print $2}')
SudoCommands=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

wall "	#Architecture: $Architecture
	#CPU physical : $PhysicalCpu
	#vCPU : $VirtualCpu
	#Memory Usage: $MemoryUsed/${MemoryTotal}MB ($MemoryPercent%)
	#Disk Usage: $DiskUsed/${DiskTotal}Gb ($DiskPercent%)
	#CPU load: $CpuLoad%
	#Last boot: $LastBoot
	#LVM Use: $LvmUsage
	#Connections TCP: $TcpConnections ESTABLISHED
	#User Log: $UserLog
	#Network: IP $NetworkIp ($NetworkMac)
	#Sudo: $SudoCommands cmd"