#!/bin/bash

# 构建 Stable-Diffusion.cpp (CUDA 版本)
# 适用于 WSL2 Ubuntu 24.04

# 颜色输出
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

echo -e "${GREEN}=== 开始构建 Stable-Diffusion.cpp (CUDA 版本) ===${NC}"

# 检查 CUDA
if ! command -v nvcc &> /dev/null; then
    echo -e "${YELLOW}警告: 未找到 CUDA Toolkit,将尝试安装${NC}"
    
    # 安装 CUDA Toolkit 12.8
    wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.1-1_all.deb
    sudo dpkg -i cuda-keyring_1.1-1_all.deb
    sudo apt-get update
    sudo apt-get install -y cuda-toolkit-12-8
    rm -f cuda-keyring_1.1-1_all.deb
    
    # 添加到 PATH
    echo "export PATH=/usr/local/cuda-12.8/bin:$PATH" >> ~/.bashrc
    echo "export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64:$LD_LIBRARY_PATH" >> ~/.bashrc
    source ~/.bashrc
fi

# 安装依赖
echo -e "${GREEN}安装系统依赖...${NC}"
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    build-essential \
    git \
    wget \
    cmake \
    ninja-build

# 克隆代码
echo -e "${GREEN}克隆 Stable-Diffusion.cpp 仓库...${NC}"
if [ ! -d "stable-diffusion.cpp" ]; then
    git clone https://github.com/leejet/stable-diffusion.cpp.git
fi

cd stable-diffusion.cpp

# 更新子模块
echo -e "${GREEN}更新子模块...${NC}"
git submodule update --init --recursive

# 构建
echo -e "${GREEN}开始构建 (CUDA 版本)...${NC}"
mkdir -p build
cd build

# 配置 CMake
echo -e "${GREEN}配置 CMake...${NC}"
cmake .. \
    -DGGML_CUDA=ON \
    -DGGML_CUDA_FORCE_MMQ=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -G Ninja

# 编译
echo -e "${GREEN}编译中...${NC}"
cmake --build . -j$(nproc)

# 验证构建
if [ -f "sd" ]; then
    echo -e "${GREEN}构建成功！${NC}"
    echo -e "${GREEN}可执行文件: $(pwd)/sd${NC}"
    echo -e "${GREEN}测试运行:${NC}"
    ./sd --help | head -20
else
    echo -e "${RED}构建失败！${NC}"
    exit 1
fi

cd ../..
echo -e "${GREEN}=== 构建完成 ===${NC}"
echo -e "${GREEN}使用方法:${NC}"
echo -e "  ${YELLOW}./stable-diffusion.cpp/build/sd -m path/to/model.safetensors -p \"prompt\" --device cuda${NC}"
