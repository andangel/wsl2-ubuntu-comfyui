#!/bin/bash

# Source config and utils
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/utils.sh"

setup_miniconda() {
    if check_and_confirm "Miniconda" "[ -d \"$HOME/miniconda3\" ]"; then
        log_info "Installing/Configuring Miniconda..."
        
        # If directory exists but user confirmed overwrite, we might need to handle it or just let the installer handle/fail
        # The installer -b -u (update) or just skip if exists? 
        # Since check_and_confirm returned true (meaning user said yes to overwrite OR it didn't exist),
        # but the check condition was "exists". So if it exists, user said YES to re-configure.
        
        if [ ! -d "$HOME/miniconda3" ]; then
            local installer="Miniconda3-py312_25.11.1-1-Linux-x86_64.sh"
            log_info "Downloading Miniconda installer..."
            wget -q "${MIRROR_ANACONDA}/miniconda/${installer}" -O /tmp/${installer} || handle_net_error
            bash /tmp/${installer} -b -p "$HOME/miniconda3"
            rm -f /tmp/${installer}
            
            # Init
            eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
            $HOME/miniconda3/bin/conda init
        else
            log_info "Miniconda directory exists. Re-running configuration..."
            eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
        fi

        # Config Mirrors
        log_info "Configuring Conda mirrors (Tsinghua)..."
        # Overwrite .condarc to use Tsinghua mirrors as default_channels
        # This avoids the "CondaToSNonInteractiveError" by not using repo.anaconda.com
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
            log_warn "Conda environment '${CONDA_ENV_NAME}' already exists."
             # We rely on the top-level confirmation or ask specifically for the env?
             # Let's just update it or leave it.
             log_info "Skipping creation of existing environment '${CONDA_ENV_NAME}'."
        else
            log_info "Creating '${CONDA_ENV_NAME}' environment with Python ${PYTHON_VERSION}..."
            conda create -n ${CONDA_ENV_NAME} python=${PYTHON_VERSION} -y
        fi
        
        log_success "Miniconda configured."
    fi
}

setup_miniconda
