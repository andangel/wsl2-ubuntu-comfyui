#!/bin/bash

set -e

echo "Building SageAttention wheel..."

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