#!/bin/bash

# GitHub520 hosts 更新脚本
# 用于在 WSL2 环境中更新 hosts 文件，提高 GitHub 访问速度

set -e

echo "=== GitHub520 hosts 更新脚本 ==="
echo "开始更新 GitHub hosts 配置..."

# 1. 备份当前 hosts 文件
echo "1. 备份当前 hosts 文件..."
sudo cp /etc/hosts /etc/hosts.bak
echo "   ✓ 备份完成: /etc/hosts.bak"

# 2. 移除旧的 GitHub520 配置
echo "2. 移除旧的 GitHub520 配置..."
sudo sed -i '/# GitHub520 Host Start/,/# GitHub520 Host End/d' /etc/hosts
echo "   ✓ 旧配置已移除"

# 3. 下载并添加新的 GitHub520 配置
echo "3. 下载最新的 GitHub520 配置..."
if curl -s https://raw.hellogithub.com/hosts >> /etc/hosts; then
    echo "   ✓ 新配置已添加"
else
    echo "   ✗ 下载失败，使用备用源..."
    if curl -s https://cdn.jsdelivr.net/gh/521xueweihan/GitHub520@main/hosts >> /etc/hosts; then
        echo "   ✓ 备用源下载成功"
    else
        echo "   ✗ 备用源也失败，更新失败"
        exit 1
    fi
fi

# 4. 显示更新结果
echo "4. 更新结果..."
echo "   ✓ GitHub hosts 配置已更新"
echo "   更新时间: $(date)"

# 5. 重启 DNS 服务以刷新缓存
echo "5. 重启 DNS 服务..."
if sudo systemctl restart systemd-resolved > /dev/null 2>&1; then
    echo "   ✓ DNS 服务已重启"
else
    echo "   ⚠ DNS 服务重启失败，可能需要手动刷新"
    echo "   尝试使用: sudo /etc/init.d/dns-clean restart"
fi

# 6. 测试 GitHub 访问
echo "6. 测试 GitHub 访问..."

# 测试 ping github.com
echo -n "   测试 github.com 连接: "
ping -c 3 github.com > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ 成功"
else
    echo "✗ 失败"
fi

# 测试 raw.githubusercontent.com
echo -n "   测试 raw.githubusercontent.com 连接: "
ping -c 3 raw.githubusercontent.com > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ 成功"
else
    echo "✗ 失败"
fi

# 测试 HTTP 响应时间
echo -n "   测试 GitHub HTTP 响应时间: "
response_time=$(curl -o /dev/null -s -w "%{time_total}" https://github.com)
if (( $(echo "$response_time < 5" | bc -l) )); then
    echo "✓ 快速 ($response_time 秒)"
else
    echo "⚠ 较慢 ($response_time 秒)"
fi

echo "=== 更新完成 ==="
echo "如果访问仍然缓慢，尝试重启 WSL 实例: wsl --terminate Comfyui"
echo "脚本会自动保存备份到 /etc/hosts.bak"
echo "如有问题，可以恢复备份: sudo cp /etc/hosts.bak /etc/hosts"
