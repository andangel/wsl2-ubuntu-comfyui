#!/bin/bash

# ComfyUI 稳定版本更新脚本
# 更新到最新的稳定版本（Tag）

echo "================================"
echo "ComfyUI 稳定版本更新"
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

# 拉取最新代码和标签
echo "正在拉取最新代码和标签..."
git pull origin master --tags

# 获取最新稳定版本标签
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

if [ -z "$LATEST_TAG" ]; then
    echo "Error: 未找到稳定版本标签"
    exit 1
fi

echo ""
echo "最新稳定版本：$LATEST_TAG"
echo "正在切换到稳定版本..."

# 切换到最新稳定版本
git checkout "$LATEST_TAG"

if [ $? -eq 0 ]; then
    echo ""
    echo "================================"
    echo "已更新到稳定版本：$LATEST_TAG"
    echo "================================"
    echo ""
    echo "版本信息："
    git log --oneline -1
    echo ""
    echo "提示：如有依赖更新，请运行："
    echo "pip install -r requirements.txt"
else
    echo ""
    echo "Error: 切换版本失败"
    exit 1
fi
