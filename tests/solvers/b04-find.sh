#!/usr/bin/env bash
mkdir -p /root/natashafiles /find/5mfiles
find / -xdev   \( -path /proc -o -path /sys -o -path /dev -o -path /run -o -path /root/natashafiles \) -prune -o   -user natasha \( -type f -o -type d \) -exec cp -a --parents -t /root/natashafiles {} +
find /opt/rhcsa-b04/findsrc -type f -size +5M -exec cp -a -t /find/5mfiles {} +
