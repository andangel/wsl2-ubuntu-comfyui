#!/bin/bash

# Source config and utils
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/utils.sh"

setup_apt() {
    if check_and_confirm "APT 配置" "grep -q 'mirrors.tuna.tsinghua.edu.cn' /etc/apt/sources.list"; then
        log_info "正在配置 APT 使用清华镜像..."
        
        if [ ! -f /etc/apt/sources.list.bak ]; then
            sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
            log_info "已备份 sources.list 到 /etc/apt/sources.list.bak"
        fi

        sudo tee /etc/apt/sources.list > /dev/null <<EOF
# 由 setup-wsl2-ubuntu 脚本配置
deb ${MIRROR_UBUNTU} noble main restricted universe multiverse
deb ${MIRROR_UBUNTU} noble-updates main restricted universe multiverse
deb ${MIRROR_UBUNTU} noble-backports main restricted universe multiverse
deb ${MIRROR_UBUNTU} noble-security main restricted universe multiverse
EOF

        log_info "正在更新 APT 缓存..."
        sudo apt-get update
        log_success "APT 配置完成。"
    fi
}

setup_apt
