#!/bin/bash

set -e

echo "Building FlashAttention wheel for Ada Lovelace (CUDA 12.8)..."

# Set environment variables
PYTHON_VERSION="3.12"
PYTORCH_VERSION="2.8.0"
CUDA_VERSION="12.8"

# Install build dependencies
echo "Installing build dependencies..."
pip install wheel ninja packaging --index-url https://pypi.org/simple
pip install torch==${PYTORCH_VERSION} torchvision --index-url https://download.pytorch.org/whl/cu${CUDA_VERSION/./}

# Clone repository
if [ ! -d "flash-attention" ]; then
    git clone https://github.com/Dao-AILab/flash-attention.git
fi

cd flash-attention

# Set build environment variables for memory optimization and CUDA architecture
export MAX_JOBS=4
export TORCH_CUDA_ARCH_LIST="8.9"

# Build wheel
echo "Building wheel..."
python setup.py bdist_wheel

echo "FlashAttention wheel built successfully!"
ls -lh dist/

# Create dist directory in root if it doesn't exist
mkdir -p ../dist

# Copy wheel to root dist directory
echo "Copying wheel to root dist directory..."
cp dist/*.whl ../dist/