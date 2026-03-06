#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[信息]${NC} $1"; }
log_success() { echo -e "${GREEN}[成功]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[警告]${NC} $1"; }
log_error() { echo -e "${RED}[错误]${NC} $1"; }

# 检查并确认操作
# 用法: check_and_confirm "描述" "检查命令"
# 返回 0 表示继续，1 表示跳过
check_and_confirm() {
    local description="$1"
    
    log_info "检查状态: $description..."
    
    # 如果检查命令返回 0 (true)，表示组件已经存在/已配置
    if eval "$2"; then
        log_warn "$description 似乎已配置。"
        read -p "是否重新配置/覆盖？[y/N] " response
        case "$response" in
            [yY][eE][sS]|[yY]) 
                return 0 
                ;;
            *)
                log_info "跳过 $description。"
                return 1
                ;;
        esac
    else
        # 未配置，继续
        return 0
    fi
}

# 网络错误处理程序
handle_net_error() {
    log_error "网络请求失败！"
    log_error "请检查网络连接后重试。"
    exit 1
}

# 检查 conda 是否可用
check_conda() {
    if ! command -v conda &> /dev/null && [ ! -f "$HOME/miniconda3/bin/conda" ]; then
        log_error "Conda 未安装或未初始化！"
        log_info "请先运行: ./main.sh --conda"
        exit 1
    fi
    
    # 如果 conda 不在 PATH 中但已安装，初始化它
    if ! command -v conda &> /dev/null && [ -f "$HOME/miniconda3/bin/conda" ]; then
        eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
    fi
}

# 检查 PyTorch 是否已安装
check_pytorch() {
    if ! python -c "import torch" 2>/dev/null; then
        log_error "PyTorch 未安装！"
        log_info "请先运行: ./main.sh --pytorch"
        exit 1
    fi
}

# 检查 CUDA Toolkit 是否已安装（编译时需要）
check_cuda_toolkit() {
    if ! command -v nvcc &> /dev/null; then
        log_error "CUDA Toolkit 未安装！"
        log_info "请先运行: ./main.sh --cudatoolkit"
        exit 1
    fi
}