#!/bin/bash

Architecture=$(uname -a)

PhysicalCpu=$(lscpu | awk '$1 == "CPU(s):" {print $2}')
VirtualCpu=$(lscpu | awk '/Thread\(s\) per core:/ {print $NF}')

MemoryTotal=$(free -m | awk '$1 == "Mem:" {print $2}')
MemoryUsed=$(free -m | awk '$1 == "Mem:" {print $3}')
MemoryPercent=$(free | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')

DiskTotal=$(df -Bg | grep '^/dev/' | grep -v '/boot$' | awk '{ft += $2} END {print ft}')
DiskUsed=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} END {print ut}')
DiskPercent=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} {ft+= $2} END {print(int(ut/ft*100))}')

CpuLoad=$(vmstat 1 2 | tail -1 | awk '{printf "%.1f\n", 100 - $15}')
LastBoot=$(who -b | awk '$1 == "system" {print $3 " " $4}')
LvmTotal=$(lsblk | grep "lvm" | wc -l)
LvmUsage=$(if [ $LvmTotal -eq 0 ]; then echo no; else echo yes; fi)
TcpConnections=$(ss -t | grep -E '^(ESTAB)' | wc -l)
UserLog=$(users | wc -w)
NetworkIp=$(hostname -I)
NetworkMac=$(ip link | awk '$1 == "link/ether" {print $2}')
SudoCommands=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

# Displaying Information
wall "	#Architecture: $Architecture
	#PhysicalCpu: $PhysicalCpu
	#VirtualCpu: $VirtualCpu
	#Memory Usage: $MemoryUsed/${MemoryTotal}MB ($MemoryPercent%)
	#Disk Usage: $DiskUsed/${DiskTotal}Gb ($DiskPercent%)
	#Cpu Load: $CpuLoad%
	#Last Boot: $LastBoot
	#Lvm Use: $LvmUsage
	#Tcp Connections: $TcpConnections ESTABLISHED
	#User Log: $UserLog
	#Network: IP $NetworkIp ($NetworkMac)
	#Sudo: $SudoCommands cmd"