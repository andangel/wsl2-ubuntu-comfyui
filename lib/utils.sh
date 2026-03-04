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
    
    log_info "Checking status: $description..."
    
    # If check command returns 0 (true), it means that component is already present/configured
    if eval "$2"; then
        log_warn "$description seems already configured."
        read -p "Reconfigure/overwrite? [y/N] " response
        case "$response" in
            [yY][eE][sS]|[yY]) 
                return 0 
                ;;
            *)
                log_info "Skipping $description."
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
    log_error "Network request failed!"
    log_error "Suggest configuring local proxy (e.g., proxychains4) and retry."
    log_info "Tip: You can use './main.sh --deps' to install proxychains4."
    log_info "If already installed, please check if proxy configuration is correct."
    log_info "For example, edit /etc/proxychains4.conf and uncomment socks4 127.0.0.1 9050."
    log_info "If you are using a different proxy port, modify accordingly."
    log_info "For example, use socks5 127.0.0.1 7891"
    log_info "Then run: proxychains4 ./main.sh ..."
    exit 1
}