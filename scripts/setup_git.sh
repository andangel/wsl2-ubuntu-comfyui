#!/bin/bash

# Source config and utils
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/utils.sh"

GIT_CONFIG_SRC="$(dirname "$0")/../git.config"
GIT_CONFIG_TEMPLATE="$(dirname "$0")/../git.config.example"
GIT_CONFIG_DEST="$HOME/.gitconfig"

setup_git() {
    if check_and_confirm "Git 客户端配置" "[ -f \"$GIT_CONFIG_DEST\" ]"; then
        log_info "正在配置 Git 客户端..."

        if [ ! -f "$GIT_CONFIG_SRC" ]; then
            log_error "未找到配置文件: $GIT_CONFIG_SRC"
            if [ -f "$GIT_CONFIG_TEMPLATE" ]; then
                log_warn "检测到模板文件: $GIT_CONFIG_TEMPLATE"
                log_warn "请先将模板复制为 git.config 并填入您的信息："
                echo -e "${YELLOW}    cp git.config.example git.config${NC}"
                echo -e "${YELLOW}    vim git.config${NC}"
            fi
            exit 1
        fi

        # Validate user.email and user.name
        # We look for 'email = something' and 'name = something' under [user]
        
        local email_configured=$(grep -E "^\s*email\s*=\s*\S+" "$GIT_CONFIG_SRC")
        local name_configured=$(grep -E "^\s*name\s*=\s*\S+" "$GIT_CONFIG_SRC")

        if [ -z "$email_configured" ] || [ -z "$name_configured" ]; then
            log_error "Git 配置验证失败！"
            log_error "检测到 $GIT_CONFIG_SRC 中的 [user] 部分尚未配置 email 或 name。"
            log_error "请编辑该文件，填写您的姓名和邮箱地址，例如："
            echo -e "${YELLOW}[user]${NC}"
            echo -e "${YELLOW}    email = your.email@example.com${NC}"
            echo -e "${YELLOW}    name = Your Name${NC}"
            exit 1
        fi

        log_info "正在将配置复制到 $GIT_CONFIG_DEST ..."
        cp "$GIT_CONFIG_SRC" "$GIT_CONFIG_DEST"
        
        log_success "Git 客户端配置完成。"
    fi
}

setup_git
