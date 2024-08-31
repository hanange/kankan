#!/bin/bash

# 检查是否安装了 curl 和 lscpu 工具
if ! command -v curl &> /dev/null || ! command -v lscpu &> /dev/null; then
    echo "错误: 此脚本需要安装 curl 和 lscpu 工具。"
    exit 1
fi

echo "=== 系统信息 ==="

# 获取系统名称和版本
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "系统名称: $NAME $VERSION"
else
    echo "系统名称: 未知"
fi

# 获取系统型号和内核版本
echo "系统型号: $(uname -s) $(uname -r)"

# 获取CPU型号和核心数
echo "CPU 型号: $(lscpu | grep 'Model name' | awk -F: '{print $2}' | sed 's/^ *//')"
echo "CPU 核心数: $(nproc)"

# 获取系统架构和虚拟化架构
echo "系统架构: $(uname -m)"
echo "虚拟化架构: $(lscpu | grep 'Virtualization' | awk -F: '{print $2}' | sed 's/^ *//')"

# 检查AES指令集支持情况
if lscpu | grep -q 'aes'; then
    echo "AES 指令支持: 已启用"
else
    echo "AES 指令支持: 未启用"
fi

# 获取磁盘使用情况
echo -e "\n=== 磁盘使用情况 ==="
df -h --total | grep "total"

# 获取内存使用情况
echo -e "\n=== 内存使用情况 ==="
free -h | awk '/Mem:/ {print "总内存: " $2 "\n已用内存: " $3 "\n可用内存: " $4}'

# 获取虚拟内存（Swap）使用情况
echo -e "\n=== 虚拟内存（Swap）使用情况 ==="
free -h | awk '/Swap:/ {print "总Swap: " $2 "\n已用Swap: " $3 "\n可用Swap: " $4}'

# 检查是否已启用 BBR 及加速方式
echo -e "\n=== BBR 启用状态 ==="
tcp_cc=$(sysctl net.ipv4.tcp_congestion_control 2>/dev/null | awk '{print $3}')
if [ "$tcp_cc" == "bbr" ]; then
    echo "BBR 已启用"
else
    echo "BBR 未启用"
fi
echo "当前TCP加速方式: $tcp_cc"

# 获取 IPv4 和 IPv6 所在地区
echo -e "\n=== 网络信息 ==="

ipv4=$(curl -s -4 ifconfig.co)
ipv6=$(curl -s -6 ifconfig.co)

ipv4_location=$(curl -s https://ipinfo.io/$ipv4 | grep 'country' | awk -F: '{print $2}' | sed 's/[", ]//g')
ipv6_location=$(curl -s https://ipinfo.io/$ipv6 | grep 'country' | awk -F: '{print $2}' | sed 's/[", ]//g')

echo "IPv4 地址: $ipv4 ($ipv4_location)"
echo "IPv6 地址: $ipv6 ($ipv6_location)"
