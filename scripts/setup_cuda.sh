#!/bin/bash

# Source config and utils
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/utils.sh"

setup_cuda() {
    local is_configured="grep -q 'cuda-12.8' ~/.bashrc 2>/dev/null"

    if check_and_confirm "CUDA Toolkit ${CUDA_VERSION}" "$is_configured"; then
        log_info "正在安装 CUDA Toolkit ${CUDA_VERSION}..."

        # Download and install CUDA keyring
        if [ ! -f /tmp/cuda-keyring_1.1-1_all.deb ]; then
            log_info "下载 CUDA keyring..."
            wget -q "${CUDA_REPO_URL}/cuda-keyring_1.1-1_all.deb" -O /tmp/cuda-keyring_1.1-1_all.deb || handle_net_error
        fi

        log_info "安装 CUDA keyring..."
        sudo dpkg -i /tmp/cuda-keyring_1.1-1_all.deb

        log_info "更新 APT 缓存..."
        sudo apt-get update

        log_info "安装 CUDA Toolkit ${CUDA_VERSION}..."
        sudo apt-get -y install cuda-toolkit-${CUDA_VERSION}

        # Add CUDA to PATH
        log_info "配置 CUDA 环境变量..."
        if ! grep -q "cuda-${CUDA_VERSION}" ~/.bashrc; then
            echo "" >> ~/.bashrc
            echo "# CUDA ${CUDA_VERSION}" >> ~/.bashrc
            echo "export PATH=/usr/local/cuda-${CUDA_VERSION}/bin:\$PATH" >> ~/.bashrc
            echo "export LD_LIBRARY_PATH=/usr/local/cuda-${CUDA_VERSION}/lib64:\$LD_LIBRARY_PATH" >> ~/.bashrc
            log_success "已将 CUDA 环境变量添加到 ~/.bashrc"
        fi

        # Clean up
        rm -f /tmp/cuda-keyring_1.1-1_all.deb

        log_success "CUDA Toolkit ${CUDA_VERSION} 安装完成。"
        log_warn "请执行 'source ~/.bashrc' 使环境变量生效。"
    fi
}

setup_cuda