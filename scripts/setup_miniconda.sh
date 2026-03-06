#!/bin/bash

# Source config and utils
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/utils.sh"

setup_miniconda() {
    if check_and_confirm "Miniconda" "[ -d \"$HOME/miniconda3\" ]"; then
        log_info "正在安装/配置 Miniconda..."
        
        if [ ! -d "$HOME/miniconda3" ]; then
            local installer="Miniconda3-py312_25.11.1-1-Linux-x86_64.sh"
            log_info "正在下载 Miniconda 安装程序..."
            wget -q "${MIRROR_ANACONDA}/miniconda/${installer}" -O /tmp/${installer} || handle_net_error
            bash /tmp/${installer} -b -p "$HOME/miniconda3"
            rm -f /tmp/${installer}
            
            # Init
            eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
            $HOME/miniconda3/bin/conda init
        else
            log_info "Miniconda 目录已存在，重新配置..."
            eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
        fi

        # Config Mirrors
        log_info "正在配置 Conda 镜像 (清华)..."
        cat > "$HOME/.condarc" <<EOF
channels:
  - defaults
show_channel_urls: true
default_channels:
  - ${MIRROR_ANACONDA}/pkgs/main
  - ${MIRROR_ANACONDA}/pkgs/r
  - ${MIRROR_ANACONDA}/pkgs/msys2
custom_channels:
  conda-forge: ${MIRROR_ANACONDA}/cloud
  pytorch: ${MIRROR_ANACONDA}/cloud
EOF

        # Create dev env
        if conda info --envs | grep -q "^${CONDA_ENV_NAME} "; then
            log_warn "Conda 环境 '${CONDA_ENV_NAME}' 已存在。"
             log_info "跳过创建已存在的环境 '${CONDA_ENV_NAME}'。"
             # Activate base environment
             log_info "Activating '${CONDA_ENV_NAME}' environment..."
             conda activate ${CONDA_ENV_NAME}
        else
            log_info "正在创建 '${CONDA_ENV_NAME}' 环境 (Python ${PYTHON_VERSION})..."
            conda create -n ${CONDA_ENV_NAME} python=${PYTHON_VERSION} -y
            # Activate base environment
            log_info "Activating '${CONDA_ENV_NAME}' environment..."
            conda activate ${CONDA_ENV_NAME}
        fi

        # Configure pip mirror (China)
        log_info "正在配置 pip 镜像 (清华)..."
        pip config set global.index-url ${PIP_INDEX_URL}
        pip config set global.trusted-host ${PIP_TRUSTED_HOST}
        
        log_success "Miniconda 配置完成。"
    fi
}

setup_miniconda
