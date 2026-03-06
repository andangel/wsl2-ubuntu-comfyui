import time
import torch
from flash_attn import flash_attn_qkvpacked_func

# 测试配置
batch_size = 32
seq_len = 1024
hidden_dim = 512
heads = 8
iterations = 100
dtype = torch.float16  # FlashAttention 需要 float16 或 bfloat16

print("Testing FlashAttention performance...")
print(f"Configuration: batch_size={batch_size}, seq_len={seq_len}, hidden_dim={hidden_dim}, heads={heads}, dtype={dtype}")

# 生成随机输入
qkv = torch.randn(batch_size, seq_len, 3, heads, hidden_dim // heads, device='cuda', dtype=dtype)
causal = True

# 预热
torch.cuda.synchronize()

# 测试FlashAttention
print("\nTesting FlashAttention...")
start = time.time()
for _ in range(iterations):
    out = flash_attn_qkvpacked_func(qkv, causal=causal)
torch.cuda.synchronize()
flash_time = time.time() - start
print(f"FlashAttention time: {flash_time:.4f} seconds")
print(f"FlashAttention average time per iteration: {flash_time/iterations:.6f} seconds")

# 测试原生PyTorch注意力
print("\nTesting PyTorch native attention...")
from torch.nn.functional import scaled_dot_product_attention
q, k, v = qkv.unbind(dim=2)
start = time.time()
for _ in range(iterations):
    out = scaled_dot_product_attention(q, k, v, is_causal=causal)
torch.cuda.synchronize()
pytorch_time = time.time() - start
print(f"PyTorch native attention time: {pytorch_time:.4f} seconds")
print(f"PyTorch native attention average time per iteration: {pytorch_time/iterations:.6f} seconds")

# 计算加速比
speedup = pytorch_time / flash_time
print(f"\nFlashAttention speedup: {speedup:.2f}x")

# 测试不同序列长度
print("\nTesting with different sequence lengths:")
seq_lengths = [512, 2048, 4096]

for seq_len in seq_lengths:
    # 生成新的输入
    qkv = torch.randn(batch_size, seq_len, 3, heads, hidden_dim // heads, device='cuda', dtype=dtype)
    q, k, v = qkv.unbind(dim=2)
    
    # 测试FlashAttention
    start = time.time()
    for _ in range(iterations // 10):  # 减少迭代次数以节省时间
        out = flash_attn_qkvpacked_func(qkv, causal=causal)
    torch.cuda.synchronize()
    flash_time = time.time() - start
    
    # 测试原生PyTorch注意力
    start = time.time()
    for _ in range(iterations // 10):
        out = scaled_dot_product_attention(q, k, v, is_causal=causal)
    torch.cuda.synchronize()
    pytorch_time = time.time() - start
    
    speedup = pytorch_time / flash_time
    print(f"Sequence length {seq_len}: FlashAttention speedup = {speedup:.2f}x")
