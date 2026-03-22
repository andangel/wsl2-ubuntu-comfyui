#!/bin/bash

# ComfyUI 符号链接设置脚本
# 用于 WSL2 环境下优化存储性能

set -e  # 遇到错误立即退出

COMFYUI_DIR="$HOME/ComfyUI"

# 目录映射配置：Windows 基础目录 -> Linux 路径
declare -A LINKS=(
    ["/mnt/e/ComfyUI-Output"]="$COMFYUI_DIR/output"           # 生成结果
    ["/mnt/e/ComfyUI-Models"]="$COMFYUI_DIR/models"          # 模型文件
    ["/mnt/e/ComfyUI-Input"]="$COMFYUI_DIR/input"            # 输入文件
)

echo "================================"
echo "ComfyUI 符号链接设置工具"
echo "================================"
echo ""

# 检查 ComfyUI 目录是否存在
if [ ! -d "$COMFYUI_DIR" ]; then
    echo "Error: ComfyUI 目录不存在：$COMFYUI_DIR"
    exit 1
fi

# 先从 Git 缓存中移除这些目录（即使 .gitignore 忽略了，也可能有例外文件）
echo "[步骤 1] 清理 Git 缓存..."
cd "$COMFYUI_DIR"
git rm -r --cached output input models 2>/dev/null || true
echo ""

# 遍历每个需要链接的目录
for windows_dir in "${!LINKS[@]}"; do
    local_path="${LINKS[$windows_dir]}"
    
    echo "处理目录：$(basename "$local_path")"
    echo "  Windows: $windows_dir"
    echo "  Linux:   $local_path"
    
    # 检查是否已是符号链接
    if [ -L "$local_path" ]; then
        # 检查符号链接是否指向正确的目标
        current_target=$(readlink "$local_path")
        if [ "$current_target" = "$windows_dir" ]; then
            echo "  [OK] 符号链接已存在且指向正确"
            echo ""
            continue
        else
            echo "  符号链接指向错误，重新创建..."
            echo "    当前指向：$current_target"
            echo "    应该指向：$windows_dir"
            rm -f "$local_path"
        fi
    fi
    
    # 如果是普通目录，直接删除（不备份）
    if [ -d "$local_path" ]; then
        echo "  删除原有目录..."
        rm -rf "$local_path"
    fi
    
    # 创建 Windows 侧目录（如果不存在）
    if [ ! -d "$windows_dir" ]; then
        echo "  创建 Windows 侧目录..."
        mkdir -p "$windows_dir"
    fi
    
    # 创建符号链接
    ln -s "$windows_dir" "$local_path"
    echo "  [OK] 已创建符号链接"
    echo ""
done

echo "================================"
echo "[完成] 符号链接设置完成！"
echo "================================"
echo ""
echo "验证链接："
ls -la "$COMFYUI_DIR" | grep -E "^l" | grep -E "(output|models|input)" || true
echo ""
echo "提示：请在 Git 中提交更改 (git commit) 以保存符号链接"