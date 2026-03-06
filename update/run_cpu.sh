#!/bin/bash

# 使用 CPU 运行 ComfyUI

# 确保 conda 环境已激活
if [ "$CONDA_DEFAULT_ENV" != "base" ]; then
    if command -v conda &> /dev/null; then
        conda activate base 2>/dev/null || true
    fi
fi

echo "使用 CPU 启动 ComfyUI..."
echo "从 Windows 浏览器访问: http://localhost:8188"
echo "按 Ctrl+C 停止服务器"
echo ""
echo "注意: CPU 模式速度较慢，建议使用 GPU 模式 (comfyui)"

COMFYUI_DIR="$HOME/ComfyUI"
if [ -d "$COMFYUI_DIR" ]; then
    cd "$COMFYUI_DIR"
    python main.py --listen 0.0.0.0 --cpu
else
    echo "错误: ComfyUI 目录不存在: $COMFYUI_DIR"
    exit 1
fi
