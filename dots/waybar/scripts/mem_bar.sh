#!/bin/sh

usage=$(free | awk '/Mem/ {printf "%.0f", $3/$2 * 100}')
bars=$(awk -v u="$usage" 'BEGIN {printf "%.0f", u/10}')

bar=""
for i in $(seq 1 10); do
    if [ "$i" -le "$bars" ]; then
        bar="${bar}█"
    else
        bar="${bar}░"
    fi
done

printf "[MEM %s]" "$bar"
