#!/bin/bash

set -e

echo "Building SAM2 wheel..."

# Clone repository
if [ ! -d "sam2" ]; then
    git clone https://github.com/facebookresearch/sam2.git
fi

cd sam2

# Install build dependencies
pip install wheel ninja packaging

# Build wheel
python setup.py bdist_wheel

echo "SAM2 wheel built successfully!"
ls -lh dist/