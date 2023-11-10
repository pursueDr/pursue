#!/bin/sh

#作者 张强
#功能 统计收包
#时间 20231018

#获取当前收包大小
start=$(ifconfig | awk 'NR>5' | head -n 1 | awk '{ print $3 }')

#等待10秒
sleep 10

#获取10秒后收包大小
stop=$(ifconfig | awk 'NR>5' | head -n 1 | awk '{ print $3 }')

#计算10秒内共收包大小
final=`expr $stop - $start`
echo "10s总共接收包的大小为：$final"

#计算10秒内接收数据包的平均大小
final1=`expr $final / 10`
echo "10s内接收数据包的平均大小为$final1"
