# kankan

### 脚本checksys.sh

依赖 curl 和 lscpu 工具，请确保这些工具已安装。访问 ipinfo.io 获取 IP 位置信息可能需要互联网连接，且此功能可能受到一些网络或防火墙限制。

脚本如下：

``wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/hanange/kankan/main/checksys.sh" && chmod 700 /root/checksys.sh && /root/checksys.sh``

### 脚本ipv4-ipv6.sh

该脚本实现开启和禁用ipv6以及ipv4和ipv6的优先级设置。

脚本如下：

``wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/hanange/kankan/main/ipv4-ipv6.sh" && chmod 700 /root/ipv4-ipv6.sh && /root/ipv4-ipv6.sh``

### 脚本checkdns.sh

该脚本实现dns查询和修改。

脚本如下：

``wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/hanange/kankan/main/checkdns.sh" && chmod 700 /root/checkdns.sh && /root/checkdns.sh``
