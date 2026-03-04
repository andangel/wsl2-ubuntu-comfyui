#!/bin/bash

set -e

log_info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }
log_success() { echo -e "\033[0;32m[SUCCESS]\033[0m $1"; }
log_warn() { echo -e "\033[0;33m[WARN]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; }

USERNAME="ubuntu"

log_info "WSL2 基础系统初始化脚本"
log_info "=================================="

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    log_error "此脚本需要以 root 身份执行"
    log_error "请使用: sudo bash $0"
    exit 1
fi

# 1. 授予用户 sudo 权限
log_info "1. 授予用户 $USERNAME sudo 权限..."
if ! groups "$USERNAME" | grep -q "\bsudo\b"; then
    usermod -aG sudo "$USERNAME"
    log_success "已授予 $USERNAME sudo 权限"
else
    log_warn "$USERNAME 已具有 sudo 权限"
fi

# 2. 配置默认登录用户
log_info "2. 配置默认登录用户为 $USERNAME..."

# 备份现有配置
if [ -f /etc/wsl.conf ]; then
    if [ ! -f /etc/wsl.conf.bak ]; then
        cp /etc/wsl.conf /etc/wsl.conf.bak
        log_info "已备份现有 /etc/wsl.conf 到 /etc/wsl.conf.bak"
    fi
fi

# 写入 wsl.conf 配置
cat > /etc/wsl.conf <<EOF
[user]
default=$USERNAME
EOF

log_success "已配置默认登录用户为 $USERNAME"

# 3. 安全设置
log_info "3. 配置安全设置..."

# 写入完整的安全配置
cat > /etc/wsl.conf <<EOF
# 启用 systemd
[boot]
systemd=true

# 设置默认用户
[user]
default=$USERNAME

# 禁用自动挂载 Windows 文件系统
[automount]
enabled = false

# 禁用 Windows PATH 环境变量追加
[interop]
appendWindowsPath = false
EOF

log_success "已配置安全设置（systemd、禁用自动挂载、禁用 Windows PATH）"

# 4. 配置 fstab（只映射 E 盘）
log_info "4. 配置 fstab（只映射 E 盘）..."

# 备份现有 fstab
if [ -f /etc/fstab ]; then
    if [ ! -f /etc/fstab.bak ]; then
        cp /etc/fstab /etc/fstab.bak
        log_info "已备份现有 /etc/fstab 到 /etc/fstab.bak"
    fi
fi

# 写入 fstab 配置
cat > /etc/fstab <<EOF
E: /mnt/e drvfs defaults 0 0
EOF

log_success "已配置 fstab（只映射 E 盘到 /mnt/e）"

# 5. 创建挂载点
log_info "5. 创建挂载点..."
mkdir -p /mnt/e
log_success "已创建挂载点 /mnt/e"

# 6. 清理历史记录
log_info "6. 清理 root 用户历史记录..."
history -c
history -w
log_success "已清理历史记录"

log_info ""
log_success "=================================="
log_success "WSL2 基础系统初始化完成！"
log_info ""
log_info "下一步："
log_info "1. 在 Windows 中执行: wsl -t <发行版名称>"
log_info "2. 在 Windows 中执行: wsl --export <发行版名称> D:\\backup\\Ubuntu-24.04.tar"
log_info "3. 在 Windows 中执行: wsl --import <新发行版> \"D:\\WSL2\\<新发行版>\" \"D:\\backup\\Ubuntu-24.04.tar\""
log_info ""
log_info "重启 WSL 后，默认用户将自动登录为 $USERNAME"