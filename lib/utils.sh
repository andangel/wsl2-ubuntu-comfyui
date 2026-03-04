#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check and confirm action
# Usage: check_and_confirm "Description" "Check Command"
# Returns 0 to proceed, 1 to skip
check_and_confirm() {
    local description="$1"
    
    log_info "检查状态: $description..."
    
    # 如果检查命令返回 0 (true)，表示组件已经存在/已配置
    if eval "$2"; then
        log_warn "$description 似乎已配置。"
        read -p "是否重新配置/覆盖？[y/N] " response
        case "$response" in
            [yY][eE][sS]|[yY]) 
                return 0 
                ;;
            *)
                log_info "跳过 $description。"
                return 1
                ;;
        esac
    else
        # Not configured, proceed
        return 0
    fi
}

# Network error handler
handle_net_error() {
    log_error "网络请求失败！"
    log_error "建议配置本地代理（如 proxychains4）后重试。"
    log_info "提示: 您可以使用 './main.sh --deps' 安装 proxychains4。"
    log_info "如果已安装，请检查代理配置是否正确。"
    log_info "例如，编辑 /etc/proxychains4.conf 并取消注释 socks4 127.0.0.1 9050。"
    log_info "如果您使用的是不同的代理端口，请相应修改。"
    log_info "例如，使用 socks5 127.0.0.1 7891"
    log_info "然后运行: proxychains4 ./main.sh ..."
    exit 1
}