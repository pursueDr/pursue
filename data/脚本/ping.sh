#!/bin/bash
for i in `cat ip.txt`
do
{
    ping -c2 -q $i &> /dev/null
    if [ $? -eq 0 ];then
    echo "$i OK" >> 1.log
    else
    echo "$i 不OK" >> 1.log
    fi
} & 
done
