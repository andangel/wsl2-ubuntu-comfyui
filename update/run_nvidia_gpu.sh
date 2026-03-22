#!/bin/bash

# 使用 NVIDIA GPU 运行 ComfyUI
# RTX 4090 (24GB 显存)

echo "启动 ComfyUI (NVIDIA GPU)..."
echo "访问地址:http://localhost:8188"
echo "按 Ctrl+C 停止"

COMFYUI_DIR="$HOME/ComfyUI"
if [ ! -d "$COMFYUI_DIR" ]; then
    echo "错误:ComfyUI 目录不存在：$COMFYUI_DIR"
    exit 1
fi

cd "$COMFYUI_DIR"
exec python main.py --listen 0.0.0.0