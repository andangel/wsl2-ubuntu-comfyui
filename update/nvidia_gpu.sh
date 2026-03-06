#!/bin/bash

# 使用 NVIDIA GPU 运行 ComfyUI（优化版）
# 适用于 RTX 4090 (24GB 显存)

# 确保 conda 环境已激活
if [ "$CONDA_DEFAULT_ENV" != "base" ]; then
    if command -v conda &> /dev/null; then
        conda activate base 2>/dev/null || true
    fi
fi

echo "使用 NVIDIA GPU 启动 ComfyUI (高性能模式)..."
echo "从 Windows 浏览器访问: http://localhost:8188"
echo "输出目录: E:\\ComfyUI-Output"
echo "按 Ctrl+C 停止服务器"

COMFYUI_DIR="$HOME/ComfyUI"
if [ -d "$COMFYUI_DIR" ]; then
    cd "$COMFYUI_DIR"
    python main.py --listen 0.0.0.0 --highvram --preview-method taesd --output-directory /mnt/e/ComfyUI-Output
else
    echo "错误: ComfyUI 目录不存在: $COMFYUI_DIR"
    exit 1
fi
