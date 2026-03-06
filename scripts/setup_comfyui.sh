#!/bin/bash

# Source config and utils
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/utils.sh"

setup_comfyui() {
    check_conda
    check_pytorch

    if check_and_confirm "ComfyUI" "[ -d \"$COMFYUI_DIR\" ]"; then
        log_info "正在安装 ComfyUI..."

        # Activate conda environment
        log_info "激活 conda 环境..."
        conda activate ${CONDA_ENV_NAME}

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

# 使用 NVIDIA GPU 运行 ComfyUI
echo "使用 NVIDIA GPU 启动 ComfyUI..."
echo "从 Windows 浏览器访问: http://localhost:8188"
echo "按 Ctrl+C 停止服务器"

# 使用系统变量确保在任何目录都能正确运行
COMFYUI_DIR="$HOME/ComfyUI"
if [ -d "$COMFYUI_DIR" ]; then
    cd "$COMFYUI_DIR"
    python3 main.py --listen 0.0.0.0
else
    echo "错误: ComfyUI 目录不存在: $COMFYUI_DIR"
    exit 1
fi
EOF
        chmod +x ~/run_nvidia_gpu.sh
        
        # 添加 ComfyUI 别名到 .bashrc
        if ! grep -q "alias comfyui" ~/.bashrc; then
            cat >> ~/.bashrc << 'EOF'

# ComfyUI alias
alias comfyui='$HOME/run_nvidia_gpu.sh'
EOF
            log_info "已添加 ComfyUI 别名到 ~/.bashrc"
            log_info "现在可以在任何目录输入 'comfyui' 启动 ComfyUI"
        else
            log_info "ComfyUI 别名已存在，跳过添加。"
        fi

        # 添加 ComfyUI 更新别名到 .bashrc
        if ! grep -q "alias comfyui-update" ~/.bashrc; then
            cat >> ~/.bashrc << 'EOF'

# ComfyUI update alias
alias comfyui-update='bash $HOME/update/update_comfyui_stable.sh'
EOF
            log_info "已添加 ComfyUI 更新别名到 ~/.bashrc"
            log_info "现在可以在任何目录输入 'comfyui-update' 更新 ComfyUI (稳定版本)"
        else
            log_info "ComfyUI 更新别名已存在，跳过添加。"
        fi

        # 复制 update 到用户 home 目录
        if [ ! -d "$HOME/update" ]; then
            log_info "复制 update 到用户 home 目录..."
            cp -r "$(dirname "$0")/../update" "$HOME/"
            chmod +x "$HOME/update/update_comfyui.sh"
            chmod +x "$HOME/update/update_comfyui_stable.sh"
            chmod +x "$HOME/update/update_comfyui_and_python_dependencies.sh"
            log_info "update 已复制到 $HOME/update"
        else
            log_info "update 目录已存在，跳过复制。"
        fi

        log_success "ComfyUI 安装完成。"
        log_info "启动脚本已创建："
        log_info "  GPU 模式: ~/run_nvidia_gpu.sh"
        log_info "访问地址: http://localhost:8188"
        log_info "别名: comfyui (在任何目录输入启动 GPU 模式)"
        log_info "更新别名: comfyui-update (在任何目录输入更新 ComfyUI 稳定版本)"
        log_info "更新目录: ~/update"
        
        log_success "ComfyUI 安装完成！正在重新加载 shell 以应用别名..."
        exec bash -l
    fi
}

setup_comfyui