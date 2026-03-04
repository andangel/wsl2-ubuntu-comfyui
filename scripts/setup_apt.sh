#!/bin/bash

# Source config and utils
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/utils.sh"

setup_apt() {
    # Idempotency check: Check if sources.list backup exists or if Tsinghua mirror is already mentioned
    if check_and_confirm "APT Configuration" "grep -q 'mirrors.tuna.tsinghua.edu.cn' /etc/apt/sources.list"; then
        log_info "Configuring APT to use Tsinghua Mirrors..."
        
        if [ ! -f /etc/apt/sources.list.bak ]; then
            sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
            log_info "Backed up sources.list to /etc/apt/sources.list.bak"
        fi

        sudo tee /etc/apt/sources.list > /dev/null <<EOF
# Default comment: sources.list configured by setup_dev_env.sh
deb ${MIRROR_UBUNTU} noble main restricted universe multiverse
deb ${MIRROR_UBUNTU} noble-updates main restricted universe multiverse
deb ${MIRROR_UBUNTU} noble-backports main restricted universe multiverse
deb ${MIRROR_UBUNTU} noble-security main restricted universe multiverse
EOF

        log_info "Updating APT cache..."
        sudo apt-get update
        log_success "APT configured."
    fi
}

setup_apt
