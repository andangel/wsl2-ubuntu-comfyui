#!/bin/bash

# Source config and utils
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/utils.sh"

FLASHATTENTION_VERSION="2.8.3"
FLASHATTENTION_DIR="$HOME/flash-attention"

setup_flashattention() {
    if check_and_confirm "FlashAttention" "[ -d \"$FLASHATTENTION_DIR\" ]"; then
        log_info "正在安装 FlashAttention..."

        # Try to download precompiled wheel from GitHub Actions
        local wheel_name="flash_attn-${FLASHATTENTION_VERSION}+cu12torch2.8cxx11abiTRUE-cp312-cp312-linux_x86_64.whl"
        local download_url="https://github.com/andangel/setup-wsl2-ubuntu/releases/download/latest/${wheel_name}"
        local temp_wheel="/tmp/${wheel_name}"

        log_info "尝试下载预编译的 FlashAttention wheel..."
        if wget -q --spider "$download_url" 2>/dev/null; then
            log_info "从 GitHub 下载预编译 wheel..."
            wget -q "$download_url" -O "$temp_wheel" || handle_net_error
            log_info "安装预编译 wheel..."
            pip install "$temp_wheel"
            rm -f "$temp_wheel"
            log_success "FlashAttention ${FLASHATTENTION_VERSION} 安装完成（使用预编译 wheel）。"
        else
            log_warn "未找到预编译 wheel，开始本地编译..."

            # Clone FlashAttention repository
            if [ ! -d "$FLASHATTENTION_DIR" ]; then
                log_info "克隆 FlashAttention 仓库..."
                git clone https://github.com/Dao-AILab/flash-attention.git ${FLASHATTENTION_DIR}
            else
                log_info "FlashAttention 目录已存在，跳过克隆。"
            fi

            # Build and install FlashAttention
            log_info "编译并安装 FlashAttention..."
            cd ${FLASHATTENTION_DIR}

            # Install build dependencies
            pip install wheel ninja packaging

            # Build wheel package
            log_info "构建 FlashAttention wheel 包..."
            python setup.py bdist_wheel

            # Find built wheel file
            local wheel_file=$(find ${FLASHATTENTION_DIR}/dist -name "flash_attn-*.whl" | head -n 1)

            if [ -z "$wheel_file" ]; then
                log_error "未找到编译好的 wheel 文件"
                exit 1
            fi

            log_info "安装 FlashAttention: $wheel_file"
            pip install "$wheel_file"

            log_success "FlashAttention ${FLASHATTENTION_VERSION} 安装完成（本地编译）。"
        fi
    fi
}

setup_flashattention