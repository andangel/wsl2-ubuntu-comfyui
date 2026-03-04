#!/bin/bash

# Source config and utils
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/utils.sh"

# Use variables from config.sh
SAM2_VERSION="${SAM2_VERSION:-1.0}"
SAM2_DIR="${SAM2_DIR:-$HOME/sam2}"
SAM2_REPO="${SAM2_REPO:-https://github.com/facebookresearch/sam2.git}"

setup_sam2() {
    if check_and_confirm "SAM2" "[ -d \"$SAM2_DIR\" ]"; then
        log_info "正在安装 SAM2..."

        # Try to download precompiled wheel from GitHub Actions
        local wheel_name="sam_2-${SAM2_VERSION}-cp312-cp312-linux_x86_64.whl"
        local download_url="https://github.com/andangel/wsl2-ubuntu-comfyui/releases/download/latest/${wheel_name}"
        local temp_wheel="/tmp/${wheel_name}"

        log_info "尝试下载预编译的 SAM2 wheel..."
        if wget -q --spider "$download_url" 2>/dev/null; then
            log_info "从 GitHub 下载预编译 wheel..."
            wget -q "$download_url" -O "$temp_wheel" || handle_net_error
            log_info "安装预编译 wheel..."
            pip install "$temp_wheel"
            rm -f "$temp_wheel"
            log_success "SAM2 ${SAM2_VERSION} 安装完成（使用预编译 wheel）。"
        else
            log_warn "未找到预编译 wheel，开始本地编译..."

            # Check if CUDA Toolkit is installed
            if ! command -v nvcc &> /dev/null; then
                log_error "CUDA Toolkit 未安装，本地编译需要 CUDA Toolkit。"
                log_info "在 WSL 环境中，编译时需要 CUDA Toolkit，推理时使用 Windows 的 CUDA 驱动。"
                log_info "请先运行 './main.sh --cudatoolkit' 安装 CUDA Toolkit，或确保已手动安装 CUDA Toolkit。"
                exit 1
            fi

            # Clone SAM2 repository
            if [ ! -d "$SAM2_DIR" ]; then
                log_info "克隆 SAM2 仓库..."
                git clone https://github.com/facebookresearch/sam2.git ${SAM2_DIR}
            else
                log_info "SAM2 目录已存在，跳过克隆。"
            fi

            # Build and install SAM2
            log_info "编译并安装 SAM2..."
            cd ${SAM2_DIR}

            # Install build dependencies
            pip install wheel ninja packaging torch==${PYTORCH_VERSION} torchvision

            # Set build environment variables for memory optimization and CUDA
            export MAX_JOBS=4
            export TORCH_CUDA_ARCH_LIST="8.9"

            # Build wheel package
            log_info "构建 SAM2 wheel 包..."
            python setup.py bdist_wheel

            # Find built wheel file
            local wheel_file=$(find ${SAM2_DIR}/dist -name "sam_2-*.whl" | head -n 1)

            if [ -z "$wheel_file" ]; then
                log_error "未找到编译好的 wheel 文件"
                exit 1
            fi

            log_info "安装 SAM2: $wheel_file"
            pip install "$wheel_file"

            log_success "SAM2 ${SAM2_VERSION} 安装完成（本地编译）。"
        fi
    fi
}

setup_sam2