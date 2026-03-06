#!/bin/bash
# 完整更新（包括依赖）
# 更新ComfyUI和Python依赖的脚本

# 确保在脚本所在目录运行
SCRIPT_DIR="$(dirname "$0")"
cd "$SCRIPT_DIR"

# 运行基本的 ComfyUI 更新脚本
./update_comfyui.sh nopause

echo "-"
echo "这将尝试更新 pytorch 和所有 python 依赖项。"
echo "-"
echo "如果您只想正常更新，请关闭此窗口并运行 update_comfyui.sh。"
echo "-"

# 暂停让用户确认
read -p "按 Enter 键继续..."

# 更新 PyTorch 和所有 Python 依赖
pip install --upgrade torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu128 -r ../ComfyUI/requirements.txt pygit2

# 最终暂停
read -p "按 Enter 键继续..."