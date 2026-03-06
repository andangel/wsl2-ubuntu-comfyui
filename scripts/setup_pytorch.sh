#!/bin/bash

# Source config and utils
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/utils.sh"

setup_pytorch() {
    check_conda

    local is_installed="python -c \"import torch; print(torch.__version__)\" 2>/dev/null | grep -q '${PYTORCH_VERSION}'"

    if check_and_confirm "PyTorch ${PYTORCH_VERSION} (CUDA 12.8)" "$is_installed"; then
        log_info "正在安装 PyTorch ${PYTORCH_VERSION}, TorchVision ${TORCHVISION_VERSION}, TorchAudio ${TORCHAUDIO_VERSION}..."

        # Activate conda environment
        log_info "激活 conda 环境..."
        conda activate ${CONDA_ENV_NAME}

        # Upgrade pip first
        log_info "升级 pip..."
        pip install --upgrade pip

        # Install PyTorch with CUDA 12.8 support
        log_info "安装 PyTorch (CUDA 12.8 版本)..."
        pip install torch==${PYTORCH_VERSION} torchvision==${TORCHVISION_VERSION} torchaudio==${TORCHAUDIO_VERSION} --index-url ${PYTORCH_INDEX_URL}

        # Verify installation
        log_info "验证 PyTorch 安装..."
        python -c "import torch; print('PyTorch 版本:', torch.__version__); print('CUDA 可用:', torch.cuda.is_available()); print('CUDA 版本:', torch.version.cuda)"

        log_success "PyTorch ${PYTORCH_VERSION} 安装完成。"
    fi
}

setup_pytorch