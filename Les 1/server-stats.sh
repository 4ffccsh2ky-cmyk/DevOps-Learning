#!/bin/bash

# ============================================================
# Server Statistics Script
# Shows CPU, Memory, Disk usage and top processes
# ============================================================

echo "===================================================="
echo "         SERVER STATISTICS REPORT"
echo "===================================================="
echo ""

# Server info
echo "Hostname: $(hostname)"
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
echo ""

# ============================================================
# CPU USAGE
# ============================================================
echo "===================================================="
echo "CPU USAGE"
echo "===================================================="

# Extract CPU usage from top
cpu_info=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

# Alternative method if above doesn't work
if [ -z "$cpu_info" ]; then
    cpu_info=$(top -bn1 | grep "%Cpu(s):" | awk -F'id,' '{print $1}' | awk '{print 100 - $NF}')
fi

if [ -z "$cpu_info" ]; then
    cpu_info="N/A"
else
    cpu_info=$(printf "%.1f" "$cpu_info")
fi

echo "Total CPU Usage: ${cpu_info}%"
echo ""

# ============================================================
# MEMORY USAGE
# ============================================================
echo "===================================================="
echo "MEMORY USAGE"
echo "===================================================="

# Get memory stats
mem_data=$(free | grep Mem:)
total_mem=$(echo "$mem_data" | awk '{print $2}')
used_mem=$(echo "$mem_data" | awk '{print $3}')
free_mem=$(echo "$mem_data" | awk '{print $4}')

# Calculate percentage
mem_percent=$(echo "scale=1; ($used_mem * 100) / $total_mem" | bc)

echo "Total Memory: $(numfmt --to=iec $((total_mem * 1024)) 2>/dev/null || echo $((total_mem / 1024)) MB)"
echo "Used Memory: $(numfmt --to=iec $((used_mem * 1024)) 2>/dev/null || echo $((used_mem / 1024)) MB) (${mem_percent}%)"
echo "Free Memory: $(numfmt --to=iec $((free_mem * 1024)) 2>/dev/null || echo $((free_mem / 1024)) MB)"
echo ""

# ============================================================
# DISK USAGE
# ============================================================
echo "===================================================="
echo "DISK USAGE (Root Filesystem)"
echo "===================================================="

# Get root filesystem disk usage
disk_data=$(df -B1 / | tail -1)
total_disk=$(echo "$disk_data" | awk '{print $2}')
used_disk=$(echo "$disk_data" | awk '{print $3}')
free_disk=$(echo "$disk_data" | awk '{print $4}')
disk_percent=$(echo "$disk_data" | awk '{print $5}')

echo "Total Disk Space: $(numfmt --to=iec $total_disk 2>/dev/null || echo $((total_disk / 1024 / 1024)) MB)"
echo "Used Disk Space: $(numfmt --to=iec $used_disk 2>/dev/null || echo $((used_disk / 1024 / 1024)) MB) (${disk_percent})"
echo "Free Disk Space: $(numfmt --to=iec $free_disk 2>/dev/null || echo $((free_disk / 1024 / 1024)) MB)"
echo ""

# ============================================================
# TOP 5 PROCESSES BY CPU USAGE
# ============================================================
echo "===================================================="
echo "TOP 5 PROCESSES BY CPU USAGE"
echo "===================================================="
echo ""

ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "%-8s %-6s %6s  %s\n", $1, $2, $3"%", $11}'
echo ""

# ============================================================
# TOP 5 PROCESSES BY MEMORY USAGE
# ============================================================
echo "===================================================="
echo "TOP 5 PROCESSES BY MEMORY USAGE"
echo "===================================================="
echo ""

ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "%-8s %-6s %6s  %s\n", $1, $2, $4"%", $11}'
echo ""

echo "===================================================="