import time
import torch
from sageattention import sageattn

# 测试配置
batch_size = 32
seq_len = 1024
hidden_dim = 512
heads = 8
iterations = 100
dtype = torch.float16  # SageAttention 需要 float16 或 bfloat16
tensor_layout = "HND"  # 张量布局

print("Testing SageAttention performance...")
print(f"Configuration: batch_size={batch_size}, seq_len={seq_len}, hidden_dim={hidden_dim}, heads={heads}, dtype={dtype}")

# 生成随机输入
q = torch.randn(batch_size, heads, seq_len, hidden_dim // heads, device='cuda', dtype=dtype)
k = torch.randn(batch_size, heads, seq_len, hidden_dim // heads, device='cuda', dtype=dtype)
v = torch.randn(batch_size, heads, seq_len, hidden_dim // heads, device='cuda', dtype=dtype)

# 预热
torch.cuda.synchronize()

# 测试 SageAttention
print("\nTesting SageAttention...")
start = time.time()
for _ in range(iterations):
    out = sageattn(q, k, v, tensor_layout=tensor_layout)
torch.cuda.synchronize()
sage_time = time.time() - start
print(f"SageAttention time: {sage_time:.4f} seconds")
print(f"SageAttention average time per iteration: {sage_time/iterations:.6f} seconds")

# 测试原生PyTorch注意力
print("\nTesting PyTorch native attention...")
from torch.nn.functional import scaled_dot_product_attention
start = time.time()
for _ in range(iterations):
    out = scaled_dot_product_attention(q, k, v, is_causal=False)
torch.cuda.synchronize()
pytorch_time = time.time() - start
print(f"PyTorch native attention time: {pytorch_time:.4f} seconds")
print(f"PyTorch native attention average time per iteration: {pytorch_time/iterations:.6f} seconds")

# 计算加速比
speedup = pytorch_time / sage_time
print(f"\nSageAttention speedup: {speedup:.2f}x")

# 测试不同序列长度
print("\nTesting with different sequence lengths:")
seq_lengths = [512, 2048, 4096]

for seq_len in seq_lengths:
    # 生成新的输入
    q = torch.randn(batch_size, heads, seq_len, hidden_dim // heads, device='cuda', dtype=dtype)
    k = torch.randn(batch_size, heads, seq_len, hidden_dim // heads, device='cuda', dtype=dtype)
    v = torch.randn(batch_size, heads, seq_len, hidden_dim // heads, device='cuda', dtype=dtype)
    
    # 测试 SageAttention
    start = time.time()
    for _ in range(iterations // 10):  # 减少迭代次数以节省时间
        out = sageattn(q, k, v, tensor_layout=tensor_layout)
    torch.cuda.synchronize()
    sage_time = time.time() - start
    
    # 测试原生PyTorch注意力
    start = time.time()
    for _ in range(iterations // 10):
        out = scaled_dot_product_attention(q, k, v, is_causal=False)
    torch.cuda.synchronize()
    pytorch_time = time.time() - start
    
    speedup = pytorch_time / sage_time
    print(f"Sequence length {seq_len}: SageAttention speedup = {speedup:.2f}x")
