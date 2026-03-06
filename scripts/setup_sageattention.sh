#!/bin/bash

# Source config and utils
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/utils.sh"

# Use variables from config.sh
SAGEATTENTION_VERSION="${SAGEATTENTION_VERSION:-2.2.0}"
SAGEATTENTION_DIR="${SAGEATTENTION_DIR:-$HOME/SageAttention}"
SAGEATTENTION_REPO="${SAGEATTENTION_REPO:-https://gitee.com/andangel/SageAttention.git}"

setup_sageattention() {
    check_conda
    check_pytorch

    if check_and_confirm "SageAttention" "[ -d \"$SAGEATTENTION_DIR\" ]"; then
        log_info "正在安装 SageAttention..."

        # Activate conda environment
        log_info "激活 conda 环境..."
        conda activate ${CONDA_ENV_NAME}

        # Try to download precompiled wheel from GitHub Actions
        local wheel_name="sageattention-${SAGEATTENTION_VERSION}-cp312-cp312-linux_x86_64.whl"
        local original_url="https://github.com/andangel/wsl2-ubuntu-comfyui/releases/download/wheels/${wheel_name}"
        local proxy_url="${GITHUB_PROXY}${original_url}"
        local temp_wheel="/tmp/${wheel_name}"
        local download_success=0

        log_info "尝试下载预编译的 SageAttention wheel..."

        # Try 1: Proxy URL (if configured)
        if [ -n "$GITHUB_PROXY" ]; then
            log_info "尝试从代理下载 (1/3)..."
            if wget -q --spider "$proxy_url" 2>/dev/null; then
                log_info "从代理下载预编译 wheel..."
                if wget -q "$proxy_url" -O "$temp_wheel" 2>/dev/null; then
                    download_success=1
                fi
            fi
        fi

        # Try 2: Original URL
        if [ $download_success -eq 0 ]; then
            log_info "尝试从 GitHub 直接下载 (2/3)..."
            if wget -q --spider "$original_url" 2>/dev/null; then
                log_info "从 GitHub 下载预编译 wheel..."
                if wget -q "$original_url" -O "$temp_wheel" 2>/dev/null; then
                    download_success=1
                fi
            fi
        fi

        # Try 3: Install if downloaded, else compile
        if [ $download_success -eq 1 ]; then
            log_info "安装预编译 wheel..."
            pip install "$temp_wheel"
            rm -f "$temp_wheel"
            log_success "SageAttention ${SAGEATTENTION_VERSION} 安装完成（使用预编译 wheel）。"
        else
            log_warn "下载预编译 wheel 失败，开始本地编译 (3/3)..."

            # Check if CUDA Toolkit is installed (required for compilation)
            if ! command -v nvcc &> /dev/null; then
                log_error "CUDA Toolkit 未安装，本地编译需要 CUDA Toolkit。"
                log_info "在 WSL 环境中，编译时需要 CUDA Toolkit，推理时使用 Windows 的 CUDA 驱动。"
                log_info "请先运行 './main.sh --cudatoolkit' 安装 CUDA Toolkit，或确保已手动安装 CUDA Toolkit。"
                exit 1
            fi

            # Clone SageAttention repository
            if [ ! -d "$SAGEATTENTION_DIR" ]; then
                log_info "克隆 SageAttention 仓库..."
                git clone ${SAGEATTENTION_REPO} ${SAGEATTENTION_DIR}
            else
                log_info "SageAttention 目录已存在，跳过克隆。"
            fi

            # Build and install SageAttention
            log_info "编译并安装 SageAttention..."
            cd ${SAGEATTENTION_DIR}

            # Install build dependencies
            pip install wheel ninja packaging torch==${PYTORCH_VERSION} torchvision
            pip install "triton>=3.0.0"

            # Set build environment variables for memory optimization and CUDA
            export EXT_PARALLEL=4
            export NVCC_APPEND_FLAGS="--threads 8"
            export MAX_JOBS=4
            export TORCH_CUDA_ARCH_LIST="8.9"

            # Build wheel package
            log_info "构建 SageAttention wheel 包..."
            python setup.py bdist_wheel

            # Find built wheel file
            local wheel_file=$(find ${SAGEATTENTION_DIR}/dist -name "sageattention-*.whl" | head -n 1)

            if [ -z "$wheel_file" ]; then
                log_error "未找到编译好的 wheel 文件"
                exit 1
            fi

            log_info "安装 SageAttention: $wheel_file"
            pip install "$wheel_file"

            log_success "SageAttention ${SAGEATTENTION_VERSION} 安装完成（本地编译）。"
        fi

        log_success "SageAttention ${SAGEATTENTION_VERSION} 安装完成。"
    fi
}

setup_sageattention