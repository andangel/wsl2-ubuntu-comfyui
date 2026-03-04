#!/bin/bash
#
# Ubuntu 24.04 (WSL2) ComfyUI 环境初始化脚本
#
# 用法: ./main.sh [选项]
#

set -e

# 加载配置和工具
source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/lib/utils.sh"

# 确保脚本具有执行权限
chmod +x "$(dirname "$0")"/scripts/*.sh

help() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --all              执行所有配置步骤"
    echo "  --apt              配置 APT 镜像源 (清华源)"
    echo "  --deps             安装基础依赖 (unzip, proxychains4, build-essential)"
    echo "  --conda            安装/配置 Miniconda & Python $PYTHON_VERSION"
    echo "  --cuda             安装 CUDA Toolkit ${CUDA_VERSION}"
    echo "  --pytorch          安装 PyTorch ${PYTORCH_VERSION} (CUDA 12.8)"
    echo "  --comfyui          安装 ComfyUI 及依赖"
    echo "  --sageattention    安装 SageAttention ${SAGEATTENTION_VERSION}"
    echo "  --flashattention    安装 FlashAttention 2.8.3"
    echo "  --sam2             安装 SAM2 1.0"
    echo "  --help             显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 --all"
    echo "  $0 --apt --conda"
    echo "  $0 --pytorch --comfyui"
    echo "  $0 --sageattention --sam2"
    echo "  $0 --flashattention --sam2"
}

# --- 主程序 ---

if [ $# -eq 0 ]; then
    help
    exit 0
fi

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            ./scripts/setup_apt.sh
            ./scripts/install_deps.sh
            ./scripts/setup_miniconda.sh
            ./scripts/setup_cuda.sh
            ./scripts/setup_pytorch.sh
            ./scripts/setup_comfyui.sh
            ./scripts/setup_sageattention.sh
            ./scripts/setup_flashattention.sh
            ./scripts/setup_sam2.sh
            shift
            ;;
        --apt)
            ./scripts/setup_apt.sh
            shift
            ;;
        --deps)
            ./scripts/install_deps.sh
            shift
            ;;
        --conda)
            ./scripts/setup_miniconda.sh
            shift
            ;;
        --cuda)
            ./scripts/setup_cuda.sh
            shift
            ;;
        --pytorch)
            ./scripts/setup_pytorch.sh
            shift
            ;;
        --comfyui)
            ./scripts/setup_comfyui.sh
            shift
            ;;
        --sageattention)
            ./scripts/setup_sageattention.sh
            shift
            ;;
        --flashattention)
            ./scripts/setup_flashattention.sh
            shift
            ;;
        --sam2)
            ./scripts/setup_sam2.sh
            shift
            ;;
        --help)
            help
            exit 0
            ;;
        *)
            echo "未知选项: $1"
            help
            exit 1
            ;;
    esac
done

log_success "请求的任务已完成！请重启 Shell 以确保所有环境变量生效。"
