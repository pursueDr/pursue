#!/bin/sh

#作者 张强
#功能 统计web服务器pv、uv，并展示前三的pv、uv
#日期 20231018

#统计pv
pv=$(cat access.log | wc -l)

#统计uv
uv=$(cat access.log | awk '{print $1}' | sort -r | uniq -c)

echo "web服务器pv为:$pv"
echo "web服务器uv为:
$uv"

#统计系统前三nv对应的ip

uv3=$(cat access.log | awk '{print $1}' | sort -r | uniq -c | sort -nr | head -n 3)
echo "前三nv对应的ip:
$uv3"
