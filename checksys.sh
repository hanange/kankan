#!/bin/bash

# 脚本版本
SCRIPT_VERSION="0.1.1"
NEW_SCRIPT_URL="https://raw.githubusercontent.com/hanange/kankan/main/checksys.sh"

echo "版本: $SCRIPT_VERSION"

# 检查是否安装了 curl 和 lscpu 工具
if ! command -v curl &> /dev/null || ! command -v lscpu &> /dev/null; then
    echo "错误: 此脚本需要安装 curl 和 lscpu 工具。"
    exit 1
fi

function show_system_info() {
    echo "=== 系统信息 ==="
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "系统名称: $NAME $VERSION"
    else
        echo "系统名称: 未知"
    fi
    echo "系统型号: $(uname -s) $(uname -r)"
}

function show_cpu_info() {
    echo "CPU 型号: $(lscpu | grep 'Model name' | awk -F: '{print $2}' | sed 's/^ *//')"
    echo "CPU 核心数: $(nproc)"
}

function show_arch_info() {
    echo "系统架构: $(uname -m)"
    echo "虚拟化架构: $(lscpu | grep 'Virtualization' | awk -F: '{print $2}' | sed 's/^ *//')"
    if lscpu | grep -q 'aes'; then
        echo "AES 指令支持: 已启用"
    else
        echo "AES 指令支持: 未启用"
    fi
}

function show_disk_usage() {
    echo -e "\n=== 磁盘使用情况 ==="
    disk_info=$(df -h --total | grep "total")
    total_disk=$(echo $disk_info | awk '{print $2}')
    used_disk=$(echo $disk_info | awk '{print $3}')
    used_disk_percent=$(echo $disk_info | awk '{print $5}')
    available_disk=$(echo $disk_info | awk '{print $4}')

    echo "总磁盘: $total_disk"
    echo "已用磁盘: $used_disk"
    echo "已用磁盘占比: $used_disk_percent"
    echo "可用磁盘: $available_disk"
}

function show_memory_usage() {
    echo -e "\n=== 内存使用情况 ==="
    free -h | awk '/Mem:/ {print "总内存: " $2 "\n已用内存: " $3 "\n可用内存: " $4}'
    echo -e "\n=== 虚拟内存（Swap）使用情况 ==="
    free -h | awk '/Swap:/ {print "总Swap: " $2 "\n已用Swap: " $3 "\n可用Swap: " $4}'
}

function show_network_info() {
    echo -e "\n=== 网络信息 ==="
    tcp_cc=$(sysctl net.ipv4.tcp_congestion_control 2>/dev/null | awk '{print $3}')
    if [ "$tcp_cc" == "bbr" ]; then
        echo "BBR 已启用"
    else
        echo "BBR 未启用"
    fi
    echo "当前TCP加速方式: $tcp_cc"

    ipv4=$(curl -s -4 ifconfig.co)
    ipv6=$(curl -s -6 ifconfig.co)

    ipv4_location=$(curl -s https://ipinfo.io/$ipv4 | grep 'country' | awk -F: '{print $2}' | sed 's/[", ]//g')
    ipv6_location=$(curl -s https://ipinfo.io/$ipv6 | grep 'country' | awk -F: '{print $2}' | sed 's/[", ]//g')

    echo "IPv4 地址: $ipv4 ($ipv4_location)"
    echo "IPv6 地址: $ipv6 ($ipv6_location)"
}

function show_all_info() {
    show_system_info
    show_cpu_info
    show_arch_info
    show_disk_usage
    show_memory_usage
    show_network_info
}

function upgrade_script() {
    echo "正在升级脚本..."
    wget -P /root -N --no-check-certificate "$NEW_SCRIPT_URL" && chmod 700 /root/checksys.sh && /root/checksys.sh
    exit 0
}

# 主循环
while true; do
    # 显示选项菜单
    echo "请选择要显示的信息："
    echo "0. 显示全部信息"
    echo "1. 显示系统信息"
    echo "2. 显示 CPU 信息"
    echo "3. 显示系统架构和虚拟化架构"
    echo "4. 显示磁盘使用情况"
    echo "5. 显示内存使用情况"
    echo "6. 显示网络信息"
    echo "9. 升级脚本"
    echo "q. 退出"
    echo -n "请输入选项 (0-6, 9, q): "

    # 读取用户输入
    read choice

    # 根据用户选择执行相应的功能
    case $choice in
        0)
            show_all_info
            ;;
        1)
            show_system_info
            ;;
        2)
            show_cpu_info
            ;;
        3)
            show_arch_info
            ;;
        4)
            show_disk_usage
            ;;
        5)
            show_memory_usage
            ;;
        6)
            show_network_info
            ;;
        9)
            upgrade_script
            ;;
        q)
            echo "退出脚本..."
            break
            ;;
        *)
            echo "无效的选项，请重试。"
            ;;
    esac

    echo -e "\n按任意键返回选项菜单..."
    read -n 1 -s
done
