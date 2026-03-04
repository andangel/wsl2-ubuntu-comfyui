#!/bin/bash

set -e

echo "Building SAM2 wheel for Ada Lovelace (CUDA 12.8)..."

# Set environment variables
PYTHON_VERSION="3.12"
PYTORCH_VERSION="2.8.0"
CUDA_VERSION="12.8"

# Install build dependencies
echo "Installing build dependencies..."
pip install wheel ninja packaging --index-url https://pypi.org/simple
pip install torch==${PYTORCH_VERSION} torchvision --index-url https://download.pytorch.org/whl/cu${CUDA_VERSION/./}

# Clone repository
if [ ! -d "sam2" ]; then
    git clone https://github.com/facebookresearch/sam2.git
fi

cd sam2

# Set build environment variables for memory optimization and CUDA architecture
export MAX_JOBS=4
export TORCH_CUDA_ARCH_LIST="8.0 8.6 8.7 8.9 9.0"

# Build wheel
echo "Building wheel..."
python setup.py bdist_wheel

echo "SAM2 wheel built successfully!"
ls -lh dist/

# Create dist directory in root if it doesn't exist
mkdir -p ../dist

# Copy wheel to root dist directory
echo "Copying wheel to root dist directory..."
cp dist/*.whl ../dist/