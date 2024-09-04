#!/bin/bash

# 版本：0.0.2

# 功能描述：一键控制 IPv4/IPv6 的优先级和状态，并提供脚本升级功能
# 兼容性：Debian、Ubuntu、CentOS

# 检查是否安装了 curl
if ! command -v curl &> /dev/null
then
    echo "curl 未安装，请先安装 curl 以继续。"
    echo "Debian/Ubuntu: sudo apt-get install curl"
    echo "CentOS: sudo yum install curl"
    exit 1
fi

# 禁用 IPv6
function disable_ipv6() {
    echo "正在禁用 IPv6..."
    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
    sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
    sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1
    sudo sysctl -p
    echo "IPv6 已禁用。"
}

# 启用 IPv6
function enable_ipv6() {
    echo "正在启用 IPv6..."
    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0
    sudo sysctl -w net.ipv6.conf.default.disable_ipv6=0
    sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=0
    sudo sysctl -p
    echo "IPv6 已启用。"
}

# 设置 IPv4 优先
function set_ipv4_priority() {
    echo "正在设置 IPv4 优先..."
    echo "precedence ::ffff:0:0/96  100" | sudo tee /etc/gai.conf > /dev/null
    echo "IPv4 优先已设置。"
}

# 设置 IPv6 优先
function set_ipv6_priority() {
    echo "正在设置 IPv6 优先..."
    sudo sed -i '/^precedence ::ffff:0:0\/96  100$/d' /etc/gai.conf
    echo "IPv6 优先已设置。"
}

# 测试优先级
function test_priority() {
    echo "正在测试网络优先级..."
    ip_output=$(curl -s ip.sb)
    
    if [[ $ip_output =~ .*:.* ]]; then
        echo "检测到的 IP 地址: $ip_output"
        echo "现在为 IPv6 优先。"
    else
        echo "检测到的 IP 地址: $ip_output"
        echo "现在为 IPv4 优先。"
    fi
}

# 升级脚本
function upgrade_script() {
    echo "正在升级脚本..."
    wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/hanange/kankan/main/ipv4-ipv6.sh" && chmod 700 /root/ipv4-ipv6.sh && /root/ipv4-ipv6.sh
    exit 0
}

# 主菜单循环
while true; do
    echo "请选择一个选项:"
    echo "1. 禁用 IPv6"
    echo "2. 启用 IPv6"
    echo "3. 设置 IPv4 优先"
    echo "4. 设置 IPv6 优先"
    echo "5. 测试网络优先级"
    echo "9. 升级脚本"
    echo "q. 退出脚本"
    echo -n "请输入选项 (1-5, 9, q): "

    # 读取用户输入
    read choice

    case $choice in
        1)
            disable_ipv6
            ;;
        2)
            enable_ipv6
            ;;
        3)
            set_ipv4_priority
            ;;
        4)
            set_ipv6_priority
            ;;
        5)
            test_priority
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

    # 回到主菜单
    echo -e "\n按任意键返回选项菜单..."
    read -n 1 -s
done
