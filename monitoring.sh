#!/bin/bash

# 'uname -a' prints: hardware machine name & info
# uname -- Print operating system name
Architecture=$(uname -a)

# Get the number of physical and virtual CPUs
# lscpu -- Display information about the CPU architecture
PhysicalCpu=$(lscpu | awk '$1 == "CPU(s):" {print $2}')
VirtualCpu=$(lscpu | awk '/Thread\(s\) per core:/ {print $NF}')

# Get memory information
# free -m -- Display amount of free and used memory in MB
MemoryTotal=$(free -m | awk '$1 == "Mem:" {print $2}')
MemoryUsed=$(free -m | awk '$1 == "Mem:" {print $3}')
MemoryPercent=$(free | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')

# Get disk usage information
# df -Bg -- Display file system disk space usage in GB
DiskTotal=$(df -Bg | grep '^/dev/' | grep -v '/boot$' | awk '{ft += $2} END {print ft}')
DiskUsed=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} END {print ut}')
DiskPercent=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} {ft+= $2} END {print(int(ut/ft*100))}')

# Get CPU load information
# vmstat -- Report virtual memory statistics
CpuLoad=$(vmstat 1 2 | tail -1 | awk '{printf "%.1f\n", 100 - $15}')

# Get system boot time
# who -b -- Display system boot time
LastBoot=$(who -b | awk '$1 == "system" {print $3 " " $4}')

# Check if LVM is in use
# lsblk -- List information about all available block devices
LvmTotal=$(lsblk | grep "lvm" | wc -l)
LvmUsage=$(if [ $LvmTotal -eq 0 ]; then echo no; else echo yes; fi)

# Get the number of established TCP connections
# ss -t -- Display TCP socket information
TcpConnections=$(ss -t | grep -E '^(ESTAB)' | wc -l)

# Get the number of users logged in
# users -- Display login names of users currently logged in
UserLog=$(users | wc -w)

# Get network information (IP address and MAC address)
# hostname -I -- Display the network address of the host name
NetworkIp=$(hostname -I)
# ip link -- Show information about network interfaces
NetworkMac=$(ip link | awk '$1 == "link/ether" {print $2}')

# Get the number of sudo commands executed
# journalctl -- Query and display messages from the journal
SudoCommands=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

# Displaying Information
# wall -- Write a message to all logged-in users
wall "#Architecture: $Architecture
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