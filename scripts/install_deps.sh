#!/bin/bash

# Source config and utils
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/utils.sh"

install_deps() {
    # Check if every tool is installed
    local is_installed=true
    for tool in $DEB_DEPS; do
        if ! command -v $tool >/dev/null; then
            is_installed=false
            break
        fi
    done

    if check_and_confirm "系统基础依赖 ($DEB_DEPS)" "$is_installed"; then
        log_info "正在安装基础依赖工具..."
        
        # Ensure apt update has run if we haven't run setup_apt recently? 
        # But setup_apt might have just run if --all was used.
        # We'll just run install.
        
        sudo apt-get install -y $DEB_DEPS
        
        log_success "基础依赖安装完成。"
    fi
}

install_deps
