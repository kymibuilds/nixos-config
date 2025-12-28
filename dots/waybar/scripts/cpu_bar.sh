#!/bin/sh

usage=$(grep 'cpu ' /proc/stat | awk '{idle=$5; total=0; for(i=2;i<=NF;i++) total+=$i;} END {print 100*(1-idle/total)}')
bars=$(awk -v u="$usage" 'BEGIN {printf "%.0f", u/10}')

bar=""
for i in $(seq 1 10); do
    if [ "$i" -le "$bars" ]; then
        bar="${bar}█"
    else
        bar="${bar}░"
    fi
done

printf "[CPU %s]" "$bar"
