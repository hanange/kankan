#!/bin/bash

# 脚本版本
SCRIPT_VERSION="0.1.0"
NEW_SCRIPT_URL="https://raw.githubusercontent.com/hanange/kankan/main/checkdns.sh"
echo "版本: $SCRIPT_VERSION"

# 刷新 DNS 配置
function refresh_dns() {
    echo "正在刷新 DNS 配置..."
    
    if command -v resolvectl &> /dev/null; then
        sudo resolvectl flush-caches
        echo "已刷新 DNS 缓存 (使用 resolvectl)。"
    elif command -v resolvconf &> /dev/null; then
        sudo resolvconf -u
        echo "已使用 resolvconf 刷新 DNS。"
    else
        echo "重启网络服务以确保 DNS 生效..."
        # 根据不同系统类型重启网络
        if [ -f /etc/debian_version ]; then
            sudo systemctl restart networking
        elif [ -f /etc/centos-release ]; then
            sudo systemctl restart NetworkManager
        else
            echo "无法确定系统类型，请手动重启网络服务。"
        fi
    fi
}

# 显示当前DNS设置
function query_dns() {
    echo "查询当前DNS设置:"
    echo "=== IPv4 DNS ==="
    cat /etc/resolv.conf | grep nameserver
    echo -e "\n=== IPv6 DNS ==="
    resolvectl status | grep 'DNS'
}

# 修改IPv4 DNS
function modify_ipv4_dns() {
    echo "请选择要使用的IPv4 DNS:"
    echo "1. Cloudflare (1.1.1.1, 1.0.0.1)"
    echo "2. Google (8.8.8.8, 8.8.4.4)"
    echo "3. 阿里云 (223.5.5.5, 223.6.6.6)"
    read -p "请输入选项 (1, 2 或 3): " dns_choice

    case $dns_choice in
        1)
            sudo sed -i '/^nameserver/ d' /etc/resolv.conf
            echo "nameserver 1.1.1.1" | sudo tee -a /etc/resolv.conf
            echo "nameserver 1.0.0.1" | sudo tee -a /etc/resolv.conf
            echo "已将 IPv4 DNS 修改为 Cloudflare (1.1.1.1, 1.0.0.1)"
            ;;
        2)
            sudo sed -i '/^nameserver/ d' /etc/resolv.conf
            echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf
            echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf
            echo "已将 IPv4 DNS 修改为 Google (8.8.8.8, 8.8.4.4)"
            ;;
        3)
            sudo sed -i '/^nameserver/ d' /etc/resolv.conf
            echo "nameserver 223.5.5.5" | sudo tee -a /etc/resolv.conf
            echo "nameserver 223.6.6.6" | sudo tee -a /etc/resolv.conf
            echo "已将 IPv4 DNS 修改为 阿里云 (223.5.5.5, 223.6.6.6)"
            ;;
        *)
            echo "无效的选项。"
            ;;
    esac

    refresh_dns
}

# 修改IPv6 DNS
function modify_ipv6_dns() {
    echo "请选择要使用的IPv6 DNS:"
    echo "1. Cloudflare (2606:4700:4700::1111, 2606:4700:4700::1001)"
    echo "2. Google (2001:4860:4860::8888, 2001:4860:4860::8844)"
    echo "3. 阿里云 (2400:3200::1, 2400:3200:baba::1)"
    read -p "请输入选项 (1, 2 或 3): " dns_choice

    case $dns_choice in
        1)
            sudo resolvectl dns eth0 2606:4700:4700::1111 2606:4700:4700::1001
            echo "已将 IPv6 DNS 修改为 Cloudflare (2606:4700:4700::1111, 2606:4700:4700::1001)"
            ;;
        2)
            sudo resolvectl dns eth0 2001:4860:4860::8888 2001:4860:4860::8844
            echo "已将 IPv6 DNS 修改为 Google (2001:4860:4860::8888, 2001:4860:4860::8844)"
            ;;
        3)
            sudo resolvectl dns eth0 2400:3200::1 2400:3200:baba::1
            echo "已将 IPv6 DNS 修改为 阿里云 (2400:3200::1, 2400:3200:baba::1)"
            ;;
        *)
            echo "无效的选项。"
            ;;
    esac

    refresh_dns
}

# 修改系统时区
function modify_timezone() {
    echo "请选择要修改的时区:"
    echo "1. 中国时区 (Asia/Shanghai)"
    echo "2. 美国时区 (America/New_York)"
    echo "3. 英国时区 (Europe/London)"
    read -p "请输入选项 (1, 2 或 3): " tz_choice

    case $tz_choice in
        1)
            sudo timedatectl set-timezone Asia/Shanghai
            echo "已将系统时区修改为 中国时区 (Asia/Shanghai)"
            ;;
        2)
            sudo timedatectl set-timezone America/New_York
            echo "已将系统时区修改为 美国时区 (America/New_York)"
            ;;
        3)
            sudo timedatectl set-timezone Europe/London
            echo "已将系统时区修改为 英国时区 (Europe/London)"
            ;;
        *)
            echo "无效的选项。"
            ;;
    esac
}

# DNS 修改菜单
function modify_dns() {
    echo "请选择要修改的DNS类型:"
    echo "1. IPv4 DNS"
    echo "2. IPv6 DNS"
    read -p "请输入选项 (1 或 2): " dns_type_choice

    case $dns_type_choice in
        1)
            modify_ipv4_dns
            ;;
        2)
            modify_ipv6_dns
            ;;
        *)
            echo "无效的选项。"
            ;;
    esac
}

# 升级脚本
function upgrade_script() {
    echo "正在升级脚本..."
    wget -O checkdns.sh "$NEW_SCRIPT_URL" && chmod +x checkdns.sh && ./checkdns.sh
    exit 0
}

# 主菜单
while true; do
    echo "=== VPS DNS 管理脚本 ==="
    echo "1. 查询 DNS 设置"
    echo "2. 修改 DNS 设置"
    echo "3. 修改系统时区"
    echo "4. 升级脚本"
    echo "q. 退出脚本"
    read -p "请输入选项 (1-4, q): " choice

    case $choice in
        1)
            query_dns
            ;;
        2)
            modify_dns
            ;;
        3)
            modify_timezone
            ;;
        4)
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

    echo -e "\n按任意键返回主菜单..."
    read -n 1 -s
done
