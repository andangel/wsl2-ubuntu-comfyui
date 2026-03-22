#!/bin/bash

# ComfyUI 快速更新脚本
# 使用 Git 直接更新到最新版本

echo "================================"
echo "ComfyUI 快速更新"
echo "================================"
echo ""

COMFYUI_DIR="$HOME/ComfyUI"

# 检查 ComfyUI 目录是否存在
if [ ! -d "$COMFYUI_DIR" ]; then
    echo "Error: ComfyUI 目录不存在：$COMFYUI_DIR"
    exit 1
fi

cd "$COMFYUI_DIR"

# 先切换到 master 分支
echo "切换到 master 分支..."
git checkout master 2>/dev/null || git checkout -b master origin/master 2>/dev/null

# 显示当前版本
echo "当前版本信息："
git log --oneline -1
echo ""

# 拉取最新代码
echo "正在拉取最新代码..."
git pull origin master

if [ $? -eq 0 ]; then
    echo ""
    echo "================================"
    echo "更新完成！"
    echo "================================"
    echo ""
    echo "新版本信息："
    git log --oneline -1
    echo ""
    echo "提示：如有依赖更新，请运行："
    echo "pip install -r requirements.txt"
else
    echo ""
    echo "Error: 更新失败"
    exit 1
fi
