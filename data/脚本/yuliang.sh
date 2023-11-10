#!/bin/sh

#作者 张强
#功能 判断硬盘的根分区是否使用剩余量低于20%
#日期 20231018

disk=$(df -h | awk '{ print $5 }' | awk 'NR>1' | head -n 1 | awk -F % '{ print $1 }')

#判断硬盘剩余量
if [ $disk -gt 80 ];then
	echo "警告！！！当前硬盘剩余空间不足20%"
fi
