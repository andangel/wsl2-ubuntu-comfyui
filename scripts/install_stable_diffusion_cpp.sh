#!/bin/bash

# 安装 Stable-Diffusion.cpp (CUDA 版本)
# 适用于 WSL2 Ubuntu 24.04
# 从 GitHub Releases 下载预编译版本

# 颜色输出
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

echo -e "${GREEN}=== 开始安装 Stable-Diffusion.cpp (CUDA 版本) ===${NC}"

# 检查系统
if [[ $(uname -r) == *microsoft* ]] || [[ $(uname -r) == *WSL* ]]; then
    echo -e "${GREEN}检测到 WSL 环境${NC}"
else
    echo -e "${YELLOW}警告：这不是 WSL 环境，可能无法正常工作${NC}"
fi

# 检查 CUDA
if ! command -v nvidia-smi &> /dev/null; then
    echo -e "${RED}错误：未检测到 NVIDIA GPU 或 CUDA 驱动${NC}"
    echo -e "${YELLOW}请确保：${NC}"
    echo -e "  1. 已安装 NVIDIA 显卡驱动"
    echo -e "  2. WSL2 已正确配置 CUDA 支持"
    echo -e "  3. 运行 nvidia-smi 可以正常显示 GPU 信息"
    exit 1
fi

echo -e "${GREEN}✓ CUDA 驱动检测通过${NC}"
nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader

# 创建安装目录
INSTALL_DIR="$HOME/.local/stable-diffusion-cpp"
BIN_DIR="$HOME/.local/bin"

echo -e "${GREEN}=== 创建安装目录 ===${NC}"
mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"

# 加载配置文件
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../config.sh" ]; then
    source "$SCRIPT_DIR/../config.sh"
    echo -e "${GREEN}✓ 已加载配置文件${NC}"
else
    echo -e "${YELLOW}警告：未找到 config.sh，将使用默认配置${NC}"
    GITHUB_PROXY=""
fi

# 下载最新版本
echo -e "${GREEN}=== 下载 Stable-Diffusion.cpp ===${NC}"
cd "$INSTALL_DIR"

# 使用 GitHub 代理（如果配置了）
if [ -n "$GITHUB_PROXY" ]; then
    RELEASE_URL="${GITHUB_PROXY}https://github.com/andangel/wsl2-ubuntu-comfyui/releases/download/stable-diffusion-cpp"
    echo -e "${GREEN}✓ 使用 GitHub 代理：$GITHUB_PROXY${NC}"
else
    RELEASE_URL="https://github.com/andangel/wsl2-ubuntu-comfyui/releases/download/stable-diffusion-cpp"
    echo -e "${YELLOW}⚠ 未配置 GitHub 代理，直接下载${NC}"
    echo -e "${YELLOW}提示：如需加速下载，请在 config.sh 中配置 GITHUB_PROXY${NC}"
fi

echo -e "${YELLOW}下载链接：$RELEASE_URL${NC}"
echo -e ""

# 下载文件
download_file() {
    local file=$1
    local url="$RELEASE_URL/$file"
    
    echo -e "${GREEN}下载 $file ...${NC}"
    if command -v wget &> /dev/null; then
        wget -q --show-progress "$url" -O "$file"
    elif command -v curl &> /dev/null; then
        curl -L "$url" -o "$file" --progress-bar
    else
        echo -e "${RED}错误：需要安装 wget 或 curl${NC}"
        echo -e "${YELLOW}运行：sudo apt-get install -y wget${NC}"
        exit 1
    fi
}

# 下载所有文件
download_file "sd-cli"
download_file "sd-server"
download_file "libstable-diffusion.so"

# 设置执行权限
echo -e "${GREEN}=== 设置文件权限 ===${NC}"
chmod +x "$INSTALL_DIR/sd-cli"
chmod +x "$INSTALL_DIR/sd-server"

# 创建符号链接
echo -e "${GREEN}=== 创建符号链接 ===${NC}"
ln -sf "$INSTALL_DIR/sd-cli" "$BIN_DIR/sd-cli"
ln -sf "$INSTALL_DIR/sd-server" "$BIN_DIR/sd-server"

# 添加到 PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "${YELLOW}添加 ~/.local/bin 到 PATH...${NC}"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    export PATH="$HOME/.local/bin:$PATH"
    echo -e "${GREEN}✓ 已添加到 PATH (需要重新加载 bashrc 或重新登录)${NC}"
fi

# 验证安装
echo -e "${GREEN}=== 验证安装 ===${NC}"
if [ -f "$INSTALL_DIR/sd-cli" ]; then
    echo -e "${GREEN}✓ sd-cli 已安装${NC}"
    echo -e "  位置：$INSTALL_DIR/sd-cli"
else
    echo -e "${RED}✗ sd-cli 安装失败${NC}"
    exit 1
fi

if [ -f "$INSTALL_DIR/sd-server" ]; then
    echo -e "${GREEN}✓ sd-server 已安装${NC}"
    echo -e "  位置：$INSTALL_DIR/sd-server"
else
    echo -e "${RED}✗ sd-server 安装失败${NC}"
    exit 1
fi

if [ -f "$INSTALL_DIR/libstable-diffusion.so" ]; then
    echo -e "${GREEN}✓ libstable-diffusion.so 已安装${NC}"
    echo -e "  位置：$INSTALL_DIR/libstable-diffusion.so"
else
    echo -e "${RED}✗ libstable-diffusion.so 安装失败${NC}"
    exit 1
fi

# 测试运行
echo -e "${GREEN}=== 测试运行 ===${NC}"
if [ -x "$BIN_DIR/sd-cli" ] || [ -x "$INSTALL_DIR/sd-cli" ]; then
    echo -e "${YELLOW}运行 sd-cli --help...${NC}"
    "$INSTALL_DIR/sd-cli" --help 2>&1 | head -10
    echo -e "${GREEN}✓ 测试成功！${NC}"
else
    echo -e "${RED}✗ 无法执行 sd-cli${NC}"
    exit 1
fi

# 显示使用说明
echo -e "${GREEN}=== 安装完成！===${NC}"
echo -e "${GREEN}使用方法：${NC}"
echo -e "  ${YELLOW}sd-cli -m path/to/model.safetensors -p \"a beautiful cat\" --device cuda${NC}"
echo -e ""
echo -e "${GREEN}常用参数说明：${NC}"
echo -e "  ${YELLOW}-m, --model <path>${NC}        模型文件路径 (.safetensors, .ckpt, .gguf)"
echo -e "  ${YELLOW}-p, --prompt <text>${NC}       正向提示词"
echo -e "  ${YELLOW}-n, --negative-prompt <text>${NC} 负向提示词"
echo -e "  ${YELLOW}-W, --width <int>${NC}         图像宽度 (默认：512)"
echo -e "  ${YELLOW}-H, --height <int>${NC}        图像高度 (默认：512)"
echo -e "  ${YELLOW}--steps <int>${NC}             采样步数 (默认：20)"
echo -e "  ${YELLOW}--cfg-scale <float>${NC}       CFG 引导系数 (默认：7.0)"
echo -e "  ${YELLOW}--seed <int>${NC}              随机种子 (默认：随机)"
echo -e "  ${YELLOW}--device <cpu|cuda>${NC}       运行设备 (默认：cpu)"
echo -e "  ${YELLOW}-o, --output <path>${NC}       输出文件路径"
echo -e "  ${YELLOW}--control-net <path>${NC}      ControlNet 模型路径"
echo -e "  ${YELLOW}--lora <path:weight>${NC}      LoRA 模型 (可多次使用)"
echo -e ""
echo -e "${GREEN}性能优化参数：${NC}"
echo -e "  ${YELLOW}--batch-size <int>${NC}        批量大小 (默认：1，增加可提高吞吐量)"
echo -e "  ${YELLOW}--threads <int>${NC}           CPU 线程数 (默认：物理核心数)"
echo -e "  ${YELLOW}--precision <fp16|fp32>${NC}   计算精度 (默认：fp16，fp16 更快)"
echo -e "  ${YELLOW}--vae-precision <fp16|fp32>${NC} VAE 精度 (默认：fp16)"
echo -e "  ${YELLOW}--clip-precision <fp16|fp32>${NC} CLIP 精度 (默认：fp16)"
echo -e "  ${YELLOW}--quantize <q4_0|q4_1|q5_0|q5_1|q8_0>${NC} 模型量化 (减少显存)"
echo -e "  ${YELLOW}--cuda-mem-pool-size <MB>${NC} CUDA 内存池大小 (默认：自动)"
echo -e ""
echo -e "${GREEN}内存优化参数：${NC}"
echo -e "  ${YELLOW}--vae-tiling${NC}              启用 VAE 分块 (减少显存占用)"
echo -e "  ${YELLOW}--vae-tiling-size <int>${NC}   VAE 分块大小 (默认：512)"
echo -e "  ${YELLOW}--diffusion-tiling${NC}        启用扩散过程分块"
echo -e "  ${YELLOW}--low-vram${NC}                低显存模式 (适合 4-6GB 显存)"
echo -e "  ${YELLOW}--very-low-vram${NC}           超低显存模式 (适合 2-4GB 显存)"
echo -e "  ${YELLOW}--cpu-offload${NC}             将部分计算卸载到 CPU"
echo -e ""
echo -e "${GREEN}高级功能参数：${NC}"
echo -e "  ${YELLOW}--sampler <name>${NC}          采样器 (euler, euler_a, dpmpp_2m, etc.)"
echo -e "  ${YELLOW}--schedule <name>${NC}         调度器 (linear, karras, exponential)"
echo -e "  ${YELLOW}--strength <float>${NC}        图生图强度 (0.0-1.0，默认：0.75)"
echo -e "  ${YELLOW}--control-weight <float>${NC}  ControlNet 权重 (默认：1.0)"
echo -e "  ${YELLOW}--control-start <float>${NC}   ControlNet 开始步数比例 (默认：0.0)"
echo -e "  ${YELLOW}--control-end <float>${NC}     ControlNet 结束步数比例 (默认：1.0)"
echo -e "  ${YELLOW}--embeddings-dir <path>${NC}   嵌入文件目录"
echo -e "  ${YELLOW}--upscale-model <path>${NC}    放大模型路径"
echo -e "  ${YELLOW}--upscale-scale <float>${NC}   放大倍数 (默认：2.0)"
echo -e ""
echo -e "${GREEN}示例：${NC}"
echo -e "  ${YELLOW}# 基础文生图${NC}"
echo -e "  sd-cli -m model.safetensors -p \"a beautiful cat\" -W 512 -H 512"
echo -e ""
echo -e "  ${YELLOW}# 使用 CUDA 加速${NC}"
echo -e "  sd-cli -m model.safetensors -p \"a beautiful cat\" --device cuda"
echo -e ""
echo -e "  ${YELLOW}# 自定义尺寸和步数${NC}"
echo -e "  sd-cli -m model.safetensors -p \"landscape\" -W 1024 -H 768 --steps 30"
echo -e ""
echo -e "  ${YELLOW}# 使用负向提示词${NC}"
echo -e "  sd-cli -m model.safetensors -p \"portrait\" -n \"ugly, deformed\" --cfg-scale 9"
echo -e ""
echo -e "  ${YELLOW}# 使用 LoRA${NC}"
echo -e "  sd-cli -m model.safetensors -p \"anime girl\" --lora \"lora-file.safetensors:0.8\""
echo -e ""
echo -e "  ${YELLOW}# 图生图${NC}"
echo -e "  sd-cli -m model.safetensors -p \"enhanced\" --init-image input.png --strength 0.7"
echo -e ""
echo -e "  ${YELLOW}# 使用 ControlNet${NC}"
echo -e "  sd-cli -m model.safetensors -p \"room\" --control-net control-canny.safetensors --control-image edge.png"
echo -e ""
echo -e "  ${YELLOW}# 性能优化 - 使用 fp16 精度和批量处理${NC}"
echo -e "  sd-cli -m model.safetensors -p \"cat\" --precision fp16 --batch-size 4 --device cuda"
echo -e ""
echo -e "  ${YELLOW}# 低显存优化 - 适合 RTX 3060 12GB${NC}"
echo -e "  sd-cli -m model.safetensors -p \"landscape\" --vae-tiling --low-vram --device cuda"
echo -e ""
echo -e "  ${YELLOW}# 超低显存优化 - 适合 RTX 3050 4GB${NC}"
echo -e "  sd-cli -m model.safetensors -p \"portrait\" --very-low-vram --vae-tiling --cpu-offload"
echo -e ""
echo -e "  ${YELLOW}# 模型量化 - 减少显存占用${NC}"
echo -e "  sd-cli -m model-q4_0.gguf -p \"cat\" --quantize q4_0"
echo -e ""
echo -e "  ${YELLOW}# 高质量输出 - 使用更好的采样器${NC}"
echo -e "  sd-cli -m model.safetensors -p \"masterpiece\" --sampler dpmpp_2m --schedule karras --steps 40"
echo -e ""
echo -e "  ${YELLOW}# 启动服务器模式${NC}"
echo -e "  sd-server --host 0.0.0.0 --port 8080"
echo -e ""
echo -e "${GREEN}文件位置：${NC}"
echo -e "  安装目录：$INSTALL_DIR"
echo -e "  可执行文件：$BIN_DIR/sd-cli"
echo -e ""
echo -e "${GREEN}服务器 API 端点：${NC}"
echo -e "  ${YELLOW}POST /txt2img${NC}      - 文生图"
echo -e "  ${YELLOW}POST /img2img${NC}      - 图生图"
echo -e "  ${YELLOW}GET  /health${NC}       - 健康检查"
echo -e ""
echo -e "${YELLOW}提示：${NC}"
echo -e "  - 如果提示找不到命令，运行：source ~/.bashrc"
echo -e "  - 或直接运行：$INSTALL_DIR/sd-cli"
echo -e "  - 查看更多参数：sd-cli --help"
echo -e "  - 服务器文档：http://localhost:8080/docs"
echo -e ""
