#!/bin/bash

# 脚本版本
SCRIPT_VERSION="0.0.1"
NEW_SCRIPT_URL="https://raw.githubusercontent.com/hanange/kankan/main/checkdns.sh"
echo "版本: $SCRIPT_VERSION"

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
    echo "1. Cloudflare (1.1.1.1)"
    echo "2. Google (8.8.8.8)"
    read -p "请输入选项 (1 或 2): " dns_choice

    case $dns_choice in
        1)
            sudo sed -i '/^nameserver/ d' /etc/resolv.conf
            echo "nameserver 1.1.1.1" | sudo tee -a /etc/resolv.conf
            echo "已将 IPv4 DNS 修改为 Cloudflare (1.1.1.1)"
            ;;
        2)
            sudo sed -i '/^nameserver/ d' /etc/resolv.conf
            echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf
            echo "已将 IPv4 DNS 修改为 Google (8.8.8.8)"
            ;;
        *)
            echo "无效的选项。"
            ;;
    esac
}

# 修改IPv6 DNS
function modify_ipv6_dns() {
    echo "请选择要使用的IPv6 DNS:"
    echo "1. Cloudflare (2606:4700:4700::1111)"
    echo "2. Google (2001:4860:4860::8888)"
    read -p "请输入选项 (1 或 2): " dns_choice

    case $dns_choice in
        1)
            sudo resolvectl dns eth0 2606:4700:4700::1111
            echo "已将 IPv6 DNS 修改为 Cloudflare (2606:4700:4700::1111)"
            ;;
        2)
            sudo resolvectl dns eth0 2001:4860:4860::8888
            echo "已将 IPv6 DNS 修改为 Google (2001:4860:4860::8888)"
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
    echo "3. 升级脚本"
    echo "q. 退出脚本"
    read -p "请输入选项 (1-3, q): " choice

    case $choice in
        1)
            query_dns
            ;;
        2)
            modify_dns
            ;;
        3)
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
