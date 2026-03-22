#!/bin/bash

# 恢复 ComfyUI 符号链接脚本
# 用于在 Git 切换分支或 tag 后恢复符号链接

echo "================================"
echo "恢复 ComfyUI 符号链接"
echo "================================"
echo ""

COMFYUI_DIR="$HOME/ComfyUI"

# 检查 ComfyUI 目录是否存在
if [ ! -d "$COMFYUI_DIR" ]; then
    echo "Error: ComfyUI 目录不存在：$COMFYUI_DIR"
    exit 1
fi

cd "$COMFYUI_DIR"

# 检查是否已经是符号链接
if [ -L "output" ] && [ -L "input" ] && [ -L "models" ]; then
    echo "符号链接已存在，无需恢复"
    echo ""
    echo "当前符号链接状态："
    ls -la "$COMFYUI_DIR" | grep -E "(output|input|models)"
    exit 0
fi

# 运行符号链接设置脚本
echo "正在恢复符号链接..."
echo ""

# 调用 comfyui_symlinks.sh
if [ -f "$HOME/comfyui_symlinks.sh" ]; then
    "$HOME/comfyui_symlinks.sh"
    echo ""
    echo "正在提交到 Git..."
    git add input models output
    git commit -m "恢复 output/input/models 符号链接"
    echo ""
    echo "================================"
    echo "符号链接已恢复并提交！"
    echo "================================"
else
    echo "Error: 找不到 comfyui_symlinks.sh"
    echo "请先创建符号链接设置脚本"
    exit 1
fi
