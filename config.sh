#!/bin/bash

# Deb Deps
DEB_DEPS="unzip build-essential gcc g++ make wget"

# Mirrors
MIRROR_UBUNTU="https://mirrors.tuna.tsinghua.edu.cn/ubuntu/"
MIRROR_ANACONDA="https://mirrors.tuna.tsinghua.edu.cn/anaconda"

# CUDA Configuration
CUDA_VERSION="12-8"
CUDA_REPO_URL="https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64"

# PyTorch Configuration
PYTORCH_VERSION="2.8.0"
TORCHVISION_VERSION="0.23.0"
TORCHAUDIO_VERSION="2.8.0"
PYTORCH_INDEX_URL="https://download.pytorch.org/whl/cu128"

# ComfyUI Configuration
COMFYUI_REPO="https://gitee.com/andangel/ComfyUI.git"
COMFYUI_DIR="$HOME/ComfyUI"

# SageAttention Configuration
SAGEATTENTION_REPO="https://gitee.com/andangel/SageAttention.git"
SAGEATTENTION_DIR="$HOME/SageAttention"
SAGEATTENTION_VERSION="2.2.0"

# FlashAttention Configuration
FLASHATTENTION_REPO="https://gitee.com/andangel/flash-attention.git"
FLASHATTENTION_DIR="$HOME/flash-attention"
FLASHATTENTION_VERSION="2.8.3"

# SAM2 Configuration
SAM2_REPO="https://gitee.com/andangel/sam2.git"
SAM2_DIR="$HOME/sam2"
SAM2_VERSION="1.0"

# pip Configuration (China Mirror)
PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"
PIP_TRUSTED_HOST="pypi.tuna.tsinghua.edu.cn"

# Versions
PYTHON_VERSION="3.12"
CONDA_ENV_NAME="base"
TRITON_VERSION="3.4.0"
