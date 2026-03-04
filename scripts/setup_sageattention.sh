#!/bin/bash

# Source config and utils
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/utils.sh"

setup_sageattention() {
    if check_and_confirm "SageAttention" "[ -d \"$SAGEATTENTION_DIR\" ]"; then
        log_info "正在安装 SageAttention..."

        # Clone SageAttention repository
        if [ ! -d "$SAGEATTENTION_DIR" ]; then
            log_info "克隆 SageAttention 仓库..."
            git clone ${SAGEATTENTION_REPO} ${SAGEATTENTION_DIR}
        else
            log_info "SageAttention 目录已存在，跳过克隆。"
        fi

        # Build and install SageAttention
        log_info "编译并安装 SageAttention..."
        cd ${SAGEATTENTION_DIR}

        # Set build environment variables
        export EXT_PARALLEL=4
        export NVCC_APPEND_FLAGS="--threads 8"
        export MAX_JOBS=32

        # Build wheel package
        log_info "构建 SageAttention wheel 包..."
        python setup.py bdist_wheel

        # Find the built wheel file
        local wheel_file=$(find ${SAGEATTENTION_DIR}/dist -name "sageattention-*.whl" | head -n 1)

        if [ -z "$wheel_file" ]; then
            log_error "未找到编译好的 wheel 文件"
            exit 1
        fi

        log_info "安装 SageAttention: $wheel_file"
        pip install "$wheel_file"

        # Create test script
        log_info "创建测试脚本..."
        cat > ~/test_sageattention.py <<'EOF'
#!/usr/bin/env python3
"""
测试 SageAttention 是否正确安装并能正常工作的脚本
"""

import torch
from sageattention import sageattn

def test_sageattention():
    """
    测试 SageAttention 的基本功能
    """
    print("开始测试 SageAttention...")
    
    # 检查 CUDA 是否可用
    if not torch.cuda.is_available():
        print("错误: CUDA 不可用，请确保 GPU 驱动已正确安装")
        return False
    
    try:
        # 创建测试数据
        print("创建测试数据...")
        q = torch.randn(1, 8, 1024, 64, device='cuda', dtype=torch.float16)
        k = torch.randn(1, 8, 1024, 64, device='cuda', dtype=torch.float16)
        v = torch.randn(1, 8, 1024, 64, device='cuda', dtype=torch.float16)
        
        # 运行 SageAttention
        print("运行 SageAttention...")
        output = sageattn(q, k, v, tensor_layout='HND', is_causal=False)
        
        # 验证输出形状
        expected_shape = (1, 8, 1024, 64)
        if output.shape == expected_shape:
            print(f"测试通过! 输出形状: {output.shape}")
            print("SageAttention 安装成功并能正常工作")
            return True
        else:
            print(f"测试失败! 预期输出形状: {expected_shape}, 实际输出形状: {output.shape}")
            return False
    
    except Exception as e:
        print(f"测试过程中出错: {e}")
        return False

def test_sageattention_different_layouts():
    """
    测试不同张量布局下的 SageAttention
    """
    print("\n测试不同张量布局...")
    
    try:
        # 创建测试数据
        q = torch.randn(1, 8, 1024, 64, device='cuda', dtype=torch.float16)
        k = torch.randn(1, 8, 1024, 64, device='cuda', dtype=torch.float16)
        v = torch.randn(1, 8, 1024, 64, device='cuda', dtype=torch.float16)
        
        # 测试 HND 布局
        output_hnd = sageattn(q, k, v, tensor_layout='HND', is_causal=False)
        print(f"HND 布局测试通过，输出形状: {output_hnd.shape}")
        
        # 测试 NHD 布局
        # 转换数据布局
        q_nhd = q.permute(0, 2, 1, 3)
        k_nhd = k.permute(0, 2, 1, 3)
        v_nhd = v.permute(0, 2, 1, 3)
        
        output_nhd = sageattn(q_nhd, k_nhd, v_nhd, tensor_layout='NHD', is_causal=False)
        print(f"NHD 布局测试通过，输出形状: {output_nhd.shape}")
        
        return True
    
    except Exception as e:
        print(f"布局测试过程中出错: {e}")
        return False

if __name__ == "__main__":
    print("=== SageAttention 测试脚本 ===")
    
    # 运行基本测试
    basic_test_passed = test_sageattention()
    
    # 运行布局测试
    layout_test_passed = test_sageattention_different_layouts()
    
    print("\n=== 测试结果汇总 ===")
    print(f"基本功能测试: {'通过' if basic_test_passed else '失败'}")
    print(f"布局测试: {'通过' if layout_test_passed else '失败'}")
    
    if basic_test_passed and layout_test_passed:
        print("\n🎉 所有测试通过! SageAttention 已成功安装并能正常工作。")
    else:
        print("\n❌ 部分测试失败，请检查安装和配置。")
EOF

        log_success "SageAttention ${SAGEATTENTION_VERSION} 安装完成。"
        log_info "运行测试脚本验证安装: python ~/test_sageattention.py"
    fi
}

setup_sageattention