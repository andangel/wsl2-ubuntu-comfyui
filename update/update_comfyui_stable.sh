#!/bin/bash

# 稳定版本的 ComfyUI 更新脚本

# 确保在脚本所在目录运行
SCRIPT_DIR="$(dirname "$0")"
cd "$SCRIPT_DIR"

# 运行更新脚本
python3 ./update.py ../ComfyUI/ --stable

# 如果有 update_new.py，就替换旧的 update.py 并再次运行
if [ -f "update_new.py" ]; then
  mv -f update_new.py update.py
  echo "更新器已更新，正在重新运行更新。"
  python3 ./update.py ../ComfyUI/ --skip_self_update --stable
fi

# 如果没有命令行参数，就暂停
if [ -z "$1" ]; then
  read -p "按 Enter 键继续..."
fi