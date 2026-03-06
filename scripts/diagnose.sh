#!/bin/bash

source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/utils.sh"

diagnose() {
    echo ""
    echo "=========================================="
    echo "  WSL2 ComfyUI 环境诊断工具"
    echo "=========================================="
    echo ""

    local all_ok=true

    # 1. 检查操作系统
    echo -e "${BLUE}[1] 操作系统${NC}"
    if grep -qi "microsoft" /proc/version 2>/dev/null; then
        echo "    ✓ WSL2 环境"
    else
        echo "    ⚠ 非 WSL 环境"
    fi
    echo "    Ubuntu: $(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)"
    echo ""

    # 2. 检查 Conda
    echo -e "${BLUE}[2] Conda 环境${NC}"
    if command -v conda &> /dev/null; then
        echo "    ✓ Conda 已安装"
        echo "    版本: $(conda --version)"
        echo "    环境: ${CONDA_DEFAULT_ENV:-未激活}"
        echo "    Python: $(python --version 2>&1)"
    else
        echo "    ✗ Conda 未安装"
        all_ok=false
    fi
    echo ""

    # 3. 检查 pip 镜像
    echo -e "${BLUE}[3] pip 镜像配置${NC}"
    if [ -f ~/.pip/pip.conf ]; then
        local pip_index=$(grep "index-url" ~/.pip/pip.conf 2>/dev/null | cut -d= -f2 | tr -d ' ')
        if [[ "$pip_index" == *"tsinghua"* ]] || [[ "$pip_index" == *"aliyun"* ]]; then
            echo "    ✓ 国内镜像已配置"
            echo "    镜像: $pip_index"
        else
            echo "    ⚠ 镜像: $pip_index"
        fi
    else
        echo "    ⚠ pip.conf 不存在，使用默认源"
    fi
    echo ""

    # 4. 检查 CUDA 驱动
    echo -e "${BLUE}[4] CUDA 驱动 (Windows)${NC}"
    if command -v nvidia-smi &> /dev/null; then
        echo "    ✓ nvidia-smi 可用"
        nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader 2>/dev/null | head -1 | while read line; do
            echo "    GPU: $line"
        done
    else
        echo "    ✗ nvidia-smi 不可用"
        echo "    请检查 Windows NVIDIA 驱动是否正确安装"
        all_ok=false
    fi
    echo ""

    # 5. 检查 CUDA Toolkit
    echo -e "${BLUE}[5] CUDA Toolkit (编译用)${NC}"
    if command -v nvcc &> /dev/null; then
        echo "    ✓ nvcc 已安装"
        echo "    版本: $(nvcc --version | grep release | awk '{print $5}' | tr -d ',')"
    else
        echo "    ⚠ nvcc 未安装 (编译时需要)"
        echo "    运行 './main.sh --cudatoolkit' 安装"
    fi
    echo ""

    # 6. 检查 PyTorch
    echo -e "${BLUE}[6] PyTorch${NC}"
    if python -c "import torch" 2>/dev/null; then
        echo "    ✓ PyTorch 已安装"
        python -c "import torch; print(f'    版本: {torch.__version__}')"
        python -c "import torch; print(f'    CUDA 可用: {torch.cuda.is_available()}')"
        python -c "import torch; print(f'    CUDA 版本: {torch.version.cuda}')" 2>/dev/null
        python -c "import torch; print(f'    cuDNN 版本: {torch.backends.cudnn.version()}')" 2>/dev/null
    else
        echo "    ✗ PyTorch 未安装"
        echo "    运行 './main.sh --pytorch' 安装"
        all_ok=false
    fi
    echo ""

    # 7. 检查 ComfyUI
    echo -e "${BLUE}[7] ComfyUI${NC}"
    if [ -d "$COMFYUI_DIR" ]; then
        echo "    ✓ ComfyUI 目录存在"
        echo "    路径: $COMFYUI_DIR"
        if [ -f "$COMFYUI_DIR/main.py" ]; then
            echo "    ✓ main.py 存在"
        fi
        if [ -f "$HOME/run_nvidia_gpu.sh" ]; then
            echo "    ✓ 启动脚本已创建"
        fi
    else
        echo "    ⚠ ComfyUI 未安装"
        echo "    运行 './main.sh --comfyui' 安装"
    fi
    echo ""

    # 8. 检查可选组件
    echo -e "${BLUE}[8] 可选组件${NC}"
    
    # SageAttention
    if python -c "import sageattention" 2>/dev/null; then
        echo "    ✓ SageAttention 已安装"
    else
        echo "    - SageAttention 未安装"
    fi

    # FlashAttention
    if python -c "import flash_attn" 2>/dev/null; then
        echo "    ✓ FlashAttention 已安装"
    else
        echo "    - FlashAttention 未安装"
    fi

    # SAM2
    if python -c "import sam2" 2>/dev/null; then
        echo "    ✓ SAM2 已安装"
    else
        echo "    - SAM2 未安装"
    fi
    echo ""

    # 9. 检查网络
    echo -e "${BLUE}[9] 网络连接${NC}"
    
    # 测试清华镜像
    if ping -c 1 -W 2 mirrors.tuna.tsinghua.edu.cn &> /dev/null; then
        echo "    ✓ 清华镜像可访问"
    else
        echo "    ⚠ 清华镜像不可访问"
    fi

    # 测试 GitHub
    if ping -c 1 -W 2 github.com &> /dev/null; then
        echo "    ✓ GitHub 可访问"
    else
        echo "    ⚠ GitHub 不可访问 (可能需要代理)"
    fi

    # 测试 PyTorch
    if curl -s --connect-timeout 5 download.pytorch.org &> /dev/null; then
        echo "    ✓ PyTorch 下载源可访问"
    else
        echo "    ⚠ PyTorch 下载源不可访问"
    fi
    echo ""
    # 总结
    echo "=========================================="
    if [ "$all_ok" = true ]; then
        echo -e "${GREEN}  环境检查通过！${NC}"
    else
        echo -e "${YELLOW}  环境检查发现问题，请根据上述提示修复。${NC}"
    fi
    echo "=========================================="
}

diagnose
