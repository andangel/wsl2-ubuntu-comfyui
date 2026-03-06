#!/bin/bash

# 基本的 ComfyUI 更新脚本

# 确保 conda 环境已激活
if [ "$CONDA_DEFAULT_ENV" != "base" ]; then
    if command -v conda &> /dev/null; then
        conda activate base 2>/dev/null || true
    fi
fi

# 确保在脚本所在目录运行
SCRIPT_DIR="$(dirname "$0")"
cd "$SCRIPT_DIR"

# 运行更新脚本
python ./update.py ../ComfyUI/

# 如果有 update_new.py，就替换旧的 update.py 并再次运行
if [ -f "update_new.py" ]; then
  mv -f update_new.py update.py
  echo "更新器已更新，正在重新运行更新。"
  python ./update.py ../ComfyUI/ --skip_self_update
fi

# 如果没有命令行参数，就暂停
if [ -z "$1" ]; then
  read -p "按 Enter 键继续..."
fi
