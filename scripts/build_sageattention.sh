#!/bin/bash

set -e

echo "Building SageAttention wheel..."

# Install triton dependency
echo "Installing triton>=3.0.0..."
pip install "triton>=3.0.0" || echo "Warning: triton installation failed"

# Clone repository
if [ ! -d "SageAttention" ]; then
    git clone https://github.com/thu-ml/SageAttention.git
fi

cd SageAttention

# Set build environment variables
export EXT_PARALLEL=4
export NVCC_APPEND_FLAGS="--threads 8"
export MAX_JOBS=32

# Build wheel
python setup.py bdist_wheel

echo "SageAttention wheel built successfully!"
ls -lh dist/