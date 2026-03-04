# CLAUDE.md - 项目上下文与开发指南

## 项目概览
本项目提供了一套模块化、灵活的 Shell 脚本套件 (`wsl2-ubuntu-comfyui`)，用于初始化和配置 Ubuntu 24.04 (WSL2) ComfyUI AI 图像生成环境。它自动化安装 AI 开发所需的工具和库，并为国内用户配置了高速镜像源（清华大学开源软件镜像站），旨在提供开箱即用的 ComfyUI 开发体验。

## 常用指令
- **执行所有配置任务**: `./main.sh --all`
- **配置特定组件**:
  - APT 镜像源: `./main.sh --apt`
  - 基础依赖: `./main.sh --deps` (unzip, build-essential)
  - Python (Conda): `./main.sh --conda` (Miniconda3, Python 3.12)
  - CUDA: `./main.sh --cuda` (CUDA Toolkit 12.8)
  - PyTorch: `./main.sh --pytorch` (PyTorch 2.8.0, CUDA 12.8)
  - ComfyUI: `./main.sh --comfyui` (ComfyUI 及依赖)
  - SageAttention: `./main.sh --sageattention` (SageAttention 2.2.0)
  - FlashAttention: `./main.sh --flashattention` (FlashAttention 2.8.3)
  - SAM2: `./main.sh --sam2` (SAM2 1.0)

## 项目结构
- `main.sh`: 主入口脚本。负责解析参数并调用具体的子脚本。
- `config.sh`: 集中化配置文件（版本号、镜像源 URL、路径配置等）。
- `lib/utils.sh`: 通用工具库，包含日志打印、颜色输出和用户确认函数。
- `init-wsl2-ubuntu.md`: WSL2 基础系统初始化指南。
- `scripts/`: 独立组件的安装/配置脚本。
  - `setup_apt.sh`: APT 软件源配置。
  - `install_deps.sh`: 基础依赖安装 (unzip, build-essential)。
  - `setup_miniconda.sh`: Miniconda 安装及 `comfyui` 环境创建。
  - `setup_CUDAToolkit.sh`: CUDA Toolkit 12.8 安装。
  - `setup_pytorch.sh`: PyTorch 2.8.0 (CUDA 12.8) 安装。
  - `setup_comfyui.sh`: ComfyUI 及依赖安装。
  - `setup_sageattention.sh`: SageAttention 2.2.0 安装（支持预编译 wheel 下载）。
  - `setup_flashattention.sh`: FlashAttention 2.8.3 安装（支持预编译 wheel 下载）。
  - `setup_sam2.sh`: SAM2 1.0 安装（支持预编译 wheel 下载）。

## 开发规范
- **语言**: Bash Shell 脚本 (`#!/bin/bash`)。
- **模块化**: 组件逻辑必须隔离在 `scripts/` 目录下。使用 `main.sh` 进行编排。
- **幂等性**: 所有脚本必须具备幂等性。在覆盖配置前，必须检查组件状态并征求用户确认。
- **配置管理**: 禁止硬编码（如 URL、版本号）。所有配置项必须在 `config.sh` 中定义。
- **镜像源**: 下载和注册表配置必须默认使用 **清华大学开源软件镜像站** (`mirrors.tuna.tsinghua.edu.cn`) 以确保国内访问速度。
- **网络健壮性**: 禁止使用 `curl ... | bash` 直接管道执行远程脚本。必须先将脚本下载到本地临时文件，检查下载状态，确认成功后再执行。
- **错误处理**: 脚本中应使用 `set -e`，确保遇到错误立即停止。
- **日志**: 使用 `lib/utils.sh` 提供的日志函数进行输出。所有用户提示信息应使用**简体中文**。

## 工具细节
- **Python**: 使用 Miniconda3，默认创建一个名为 `comfyui` 的环境，Python 版本为 3.12。
- **CUDA**: 安装 CUDA Toolkit 12.8，为 PyTorch 和 AI 模型提供 GPU 加速。
- **PyTorch**: 安装 PyTorch 2.8.0 (CUDA 12.8 版本)，包含 TorchVision 和 TorchAudio。
- **Triton**: 自动安装 Triton 3.4.0 性能优化库。
- **ComfyUI**: 自动克隆并安装 ComfyUI 及其依赖，提供 AI 图像生成功能。
- **SageAttention**: 自动下载预编译 wheel 或编译安装 SageAttention 2.2.0 优化器。
- **FlashAttention**: 自动下载预编译 wheel 或编译安装 FlashAttention 2.8.3。
- **SAM2**: 自动下载预编译 wheel 或编译安装 SAM2 1.0。
- **GitHub Actions**: 配置自动编译预编译 wheel 包，加速安装过程。

## 项目变更记录
- **项目定位**: 从通用 WSL2 配置工具转变为专门的 ComfyUI 环境配置工具。
- **目标系统**: 从 Ubuntu 22.04 升级到 Ubuntu 24.04 LTS。
- **核心功能**: 移除了通用开发工具配置，专注于 AI 图像生成环境。
- **依赖管理**: 移除了 proxychains4 等不需要的依赖，添加了 CUDA、PyTorch 等 AI 相关依赖。
- **脚本结构**: 移除了 setup_git.sh、setup_wsl.sh 等脚本，添加了 setup_CUDAToolkit.sh、setup_pytorch.sh 等 AI 相关脚本。
- **配置优化**: 更新了 Python 版本为 3.12，添加了 CUDA 12.8 等配置。
- **GitHub 集成**: 添加了 GitHub Actions 自动编译预编译 wheel 包的功能。