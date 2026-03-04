#!/bin/bash

set -e

echo "Building FlashAttention wheel..."

# Clone repository
if [ ! -d "flash-attention" ]; then
    git clone https://github.com/Dao-AILab/flash-attention.git
fi

cd flash-attention

# Install build dependencies
pip install wheel ninja packaging

# Build wheel
python setup.py bdist_wheel

echo "FlashAttention wheel built successfully!"
ls -lh dist/