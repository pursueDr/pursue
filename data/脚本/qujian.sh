#!/bin/sh

#作者 张强
#功能 3秒内所有访问用户IP的总量统计
#日期 20231018

#获取当前时间
date_start=$(date | awk '{ print $4 }')
sleep 3

#获取3s后时间
date_stop=$(date | awk '{ print $4 }')

ip=$(cat access.log | sed -e "/$date_start/,/$date_stop/p" | awk '{ print $1 }' | sort | uniq -c  | awk '{ print $2 }' | wc -l)

echo "3s内所有访问用户的ip为:$ip 个"
