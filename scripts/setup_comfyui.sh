#!/bin/bash

# Source config and utils
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/utils.sh"

setup_comfyui() {
    if check_and_confirm "ComfyUI" "[ -d \"$COMFYUI_DIR\" ]"; then
        log_info "正在安装 ComfyUI..."

        # Clone ComfyUI repository
        if [ ! -d "$COMFYUI_DIR" ]; then
            log_info "克隆 ComfyUI 仓库..."
            git clone ${COMFYUI_REPO} ${COMFYUI_DIR}
        else
            log_info "ComfyUI 目录已存在，跳过克隆。"
        fi

        # Install dependencies
        log_info "安装 ComfyUI 依赖..."
        pip install pygit2
        pip install -r ${COMFYUI_DIR}/requirements.txt

        # Install Triton
        log_info "安装 Triton ${TRITON_VERSION}..."
        pip install "triton>=${TRITON_VERSION}"

        # Create launch scripts
        log_info "创建启动脚本..."

        # GPU launch script
        cat > ~/run_nvidia_gpu.sh <<'EOF'
#!/bin/bash

# 检查是否激活了 conda 虚拟环境
if [ -z "$CONDA_DEFAULT_ENV" ]; then
  echo "未激活 conda 虚拟环境，正在激活 base..."
  # 尝试激活虚拟环境
  if [ -f ~/miniconda3/etc/profile.d/conda.sh ]; then
    source ~/miniconda3/etc/profile.d/conda.sh
    conda activate base
  else
    echo "警告: 无法找到 conda 配置文件，请手动激活虚拟环境后再运行脚本。"
  fi
fi

# 使用 NVIDIA GPU 运行 ComfyUI
echo "使用 NVIDIA GPU 启动 ComfyUI..."
echo "从 Windows 浏览器访问: http://localhost:8188"
echo "按 Ctrl+C 停止服务器"

python3 ComfyUI/main.py --listen 0.0.0.0
EOF
        chmod +x ~/run_nvidia_gpu.sh

        # CPU launch script
        cat > ~/run_cpu.sh <<'EOF'
#!/bin/bash

# 检查是否激活了 conda 虚拟环境
if [ -z "$CONDA_DEFAULT_ENV" ]; then
  echo "未激活 conda 虚拟环境，正在激活 base..."
  # 尝试激活虚拟环境
  if [ -f ~/miniconda3/etc/profile.d/conda.sh ]; then
    source ~/miniconda3/etc/profile.d/conda.sh
    conda activate base
  else
    echo "警告: 无法找到 conda 配置文件，请手动激活虚拟环境后再运行脚本。"
  fi
fi

# 使用 CPU 运行 ComfyUI
echo "使用 CPU 启动 ComfyUI..."
echo "从 Windows 浏览器访问: http://localhost:8188"
echo "按 Ctrl+C 停止服务器"

python3 ComfyUI/main.py --cpu --listen 0.0.0.0
EOF
        chmod +x ~/run_cpu.sh

        log_success "ComfyUI 安装完成。"
        log_info "启动脚本已创建："
        log_info "  GPU 模式: ~/run_nvidia_gpu.sh"
        log_info "  CPU 模式: ~/run_cpu.sh"
        log_info "访问地址: http://localhost:8188"
    fi
}

setup_comfyui