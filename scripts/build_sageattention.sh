#!/bin/bash

set -e

echo "Building SageAttention wheel for Ada Lovelace (CUDA 12.8)..."

# Set environment variables
PYTHON_VERSION="3.12"
PYTORCH_VERSION="2.8.0"
CUDA_VERSION="12.8"

# Install build dependencies
echo "Installing build dependencies..."
pip install wheel ninja packaging --index-url https://pypi.org/simple
pip install torch==${PYTORCH_VERSION} torchvision --index-url https://download.pytorch.org/whl/cu${CUDA_VERSION/./}

# Install triton dependency
echo "Installing triton>=3.0.0..."
pip install "triton>=3.0.0" --index-url https://pypi.org/simple

# Clone repository
if [ ! -d "SageAttention" ]; then
    git clone https://github.com/thu-ml/SageAttention.git
fi

cd SageAttention

# Set build environment variables for memory optimization and CUDA architecture
export EXT_PARALLEL=4
export NVCC_APPEND_FLAGS="--threads 8"
export MAX_JOBS=4
export TORCH_CUDA_ARCH_LIST="8.0 8.6 8.7 8.9 9.0"

# Build wheel
echo "Building wheel..."
python setup.py bdist_wheel

echo "SageAttention wheel built successfully!"
ls -lh dist/