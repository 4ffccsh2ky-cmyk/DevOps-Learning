#!/bin/bash

echo "=== Server Status ==="
echo ""

echo "Hostname:"
hostname

echo ""
echo "Uptime:"
uptime

echo ""
echo "=== CPU ==="
top -bn1 | grep "Cpu"

echo ""
echo "=== Geheugen ==="
free -h

echo ""
echo "=== Schijven ==="
df -h

echo ""
echo "=== Hoofd IP ==="
hostname -I