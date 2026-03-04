# Ubuntu 24.04 (WSL2) ComfyUI 环境初始化脚本

这是一个用于快速配置 Ubuntu 24.04 (WSL2) ComfyUI AI 图像生成环境的 Shell 脚本套件。它集成了国内高速镜像源（清华大学开源软件镜像站），并自动化安装 CUDA、PyTorch、ComfyUI 等 AI 开发工具，旨在提供开箱即用的 ComfyUI 开发体验。

## ✨ 特性

- **国内加速**：APT、Conda、PyTorch 等均默认配置清华/国内镜像源，大幅提升下载速度。
- **模块化设计**：支持一键全量安装，也支持按需单独配置特定组件。
- **WSL2 优化**：针对 WSL2 环境优化的基础配置（systemd、PATH 隔离、自动挂载）。
- **幂等性**：内置状态检查，重复运行会提示确认，避免误覆盖现有配置。
- **AI 工具链集成**：
    - **基础依赖**: 自动安装 unzip、proxychains4、build-essential 等常用工具。
    - **WSL 配置**: 自动配置 `/etc/wsl.conf` (systemd、PATH 隔离、禁用自动挂载)。
    - **Git**: 自动配置 `~/.gitconfig`，强制校验用户信息。
    - **Python**: Miniconda3 (默认创建 Python 3.12 `comfyui` 环境)
    - **CUDA**: 自动安装 CUDA Toolkit 12.8
    - **PyTorch**: 安装 PyTorch 2.8.0 (CUDA 12.8 版本)
    - **ComfyUI**: 自动克隆并安装 ComfyUI 及其依赖
    - **SageAttention**: 自动下载预编译 wheel 或编译安装 SageAttention 2.2.0 优化器
    - **FlashAttention**: 自动下载预编译 wheel 或编译安装 FlashAttention 2.8.3
    - **SAM2**: 自动下载预编译 wheel 或编译安装 SAM2 1.0
    - **Triton**: 自动安装 Triton 3.4.0 性能优化库
    - **GitHub Actions**: 自动编译预编译 wheel 包，加速安装过程

## 🖥 WSL2 基础系统初始化

在使用本脚本之前，需要先创建 WSL2 基础系统。以下是完整的初始化步骤：

### 1. 目录创建
```cmd
mkdir D:\Backup -Force
mkdir D:\WSL2\Comfyui -Force
```

### 2. 导入基础系统
```cmd
wsl --import Ubuntu24 "D:\WSL2\Comfyui" "D:\Backup\install.tar.gz" --version 2
```

### 3. 首次登录与用户配置

#### 3.1 以 root 身份首次登录
```cmd
wsl -d Comfyui
```

#### 3.2 授予用户 sudo 权限
```bash
usermod -aG sudo ubuntu
```

#### 3.3 配置默认登录用户
```bash
nano /etc/wsl.conf
```

填入以下内容：
```ini
[user]
default=ubuntu
```

保存并退出（nano 中按 Ctrl+O 回车保存，Ctrl+X 退出）

#### 3.4 终止指定发行版
```cmd
wsl -t Comfyui
```

#### 3.5 测试 ubuntu 用户权限
```bash
sudo apt update
sudo apt upgrade
```

#### 3.6 切换至 root 用户清理历史记录
```cmd
wsl -d Comfyui -u root
```

```bash
# 清理历史记录
history -c && history -w
```

#### 3.7 安全设置
```bash
nano /etc/wsl.conf
```

填入以下内容：
```ini
# 启用systemd
[boot]
systemd=true
# 设置默认用户为ubuntu
[user]
default=ubuntu
# 禁用自动挂载Windows文件系统
[automount]
enabled = false
# 禁用Windows PATH 环境变量追加
[interop]
appendWindowsPath = false
```

```bash
sudo nano /etc/fstab
# 填入以下内容，只映射E盘
E: /mnt/e drvfs defaults 0 0
```

### 4. 系统备份
```cmd
wsl --export Comfyui D:\backup\Ubuntu-24.04.tar
```

### 5. 导入系统（可选）
```cmd
wsl --import Comfyui "D:\WSL2\Comfyui" "D:\backup\Ubuntu-24.04.tar" --version 2
```

## 🚀 快速开始

1.  **赋予执行权限**
    ```bash
    chmod +x main.sh scripts/*.sh
    ```

2.  **配置 Git 用户信息**
    复制配置文件模板并填入您的姓名和邮箱：
    ```bash
    cp git.config.example git.config
    ```
    编辑 `git.config`：
    ```ini
    [user]
        email = your.email@example.com
        name = Your Name
    ```

3.  **一键全量配置** (推荐)
    ```bash
    ./main.sh --all
    ```

## 📖 使用指南

### 常用命令选项

| 功能 | 命令 | 说明 |
| :--- | :--- | :--- |
| **全量配置** | `./main.sh --all` | 执行所有初始化任务 |
| **APT 换源** | `./main.sh --apt` | 备份原源，替换为清华源并更新缓存 |
| **基础依赖** | `./main.sh --deps` | 安装 unzip、proxychains4、build-essential 等基础工具 |
| **WSL 配置** | `./main.sh --wsl` | 配置 `/etc/wsl.conf` (启用 systemd、禁用自动挂载) |
| **Git 配置** | `./main.sh --git` | 检查并复制 `git.config` 到 `~/.gitconfig` |
| **Python (Conda)** | `./main.sh --conda` | 安装 Miniconda & 创建 `comfyui` 环境 |
| **CUDA** | `./main.sh --cuda` | 安装 CUDA Toolkit 12.8 |
| **PyTorch** | `./main.sh --pytorch` | 安装 PyTorch 2.8.0 (CUDA 12.8) |
| **ComfyUI** | `./main.sh --comfyui` | 安装 ComfyUI 及依赖 |
| **SageAttention** | `./main.sh --sageattention` | 安装 SageAttention 2.2.0 |
| **FlashAttention** | `./main.sh --flashattention` | 安装 FlashAttention 2.8.3 |
| **SAM2** | `./main.sh --sam2` | 安装 SAM2 1.0 |

### 自定义配置

所有可配置项（如镜像源 URL、版本号、仓库地址等）均集中在 [config.sh](config.sh) 文件中。

## 📂 项目结构

```text
.
├── main.sh                 # 主入口脚本，负责参数解析和流程控制
├── config.sh               # 配置文件，定义全局变量
├── git.config.example      # Git 配置文件模板
├── CLAUDE.md               # 项目上下文与开发规范文档
├── lib/
│   └── utils.sh            # 通用工具库（日志、颜色、交互确认）
└── scripts/                # 独立组件安装脚本
    ├── setup_apt.sh
    ├── install_deps.sh
    ├── setup_wsl.sh
    ├── setup_git.sh
    ├── setup_miniconda.sh
    ├── setup_cuda.sh
    ├── setup_pytorch.sh
    ├── setup_comfyui.sh
    ├── setup_sageattention.sh
    ├── setup_flashattention.sh
    └── setup_sam2.sh
```

## ⚠️ 注意事项

1.  **Git 配置**：运行 `--git` 或 `--all` 之前，**必须**从 `git.config.example` 复制并修改生成 `git.config` 文件。如果未配置，脚本会报错并停止执行。
2.  **Shell 重启**：脚本执行完毕后，建议重启终端或执行 `source ~/.bashrc`，以确保环境变量立即生效。
3.  **WSL 重启**：运行 `--wsl` 后，需要执行 `wsl --shutdown` 重启 WSL 实例以使配置生效。
4.  **CUDA 安装**：CUDA Toolkit 12.8 安装需要较长时间，请耐心等待。
5.  **预编译 Wheel**：脚本会优先从 GitHub Releases 下载预编译的 wheel 包（SageAttention、FlashAttention、SAM2），如果下载失败则会自动进行本地编译。
6.  **本地编译**：如果预编译 wheel 不可用，脚本会自动进行本地编译，确保已安装 `build-essential`、`gcc`、`g++`、`make` 等编译工具。
7.  **GPU 要求**：本环境需要 NVIDIA GPU 支持，建议显存 >= 8GB。

## 🎯 启动 ComfyUI

安装完成后，可以使用以下脚本启动 ComfyUI：

- **使用 GPU 启动**：
    ```bash
    bash ~/run_nvidia_gpu.sh
    ```
- **使用 CPU 启动**：
    ```bash
    bash ~/run_cpu.sh
    ```
- **访问 ComfyUI**：
    - 在 Windows 浏览器中访问：http://localhost:8188

## 🔧 测试 SageAttention

安装 SageAttention 后，可以运行测试脚本验证安装：

```bash
python ~/test_sageattention.py
```

## 📋 技术栈

| 组件 | 版本 | 用途 |
|------|------|------|
| WSL2 Ubuntu | 24.04 LTS | 操作系统 |
| Miniconda | 3 (Python 3.12) | Python 环境管理 |
| CUDA | 12.8 | GPU 加速计算 |
| PyTorch | 2.8.0 | 深度学习框架 |
| TorchVision | 0.23.0 | 计算机视觉库 |
| TorchAudio | 2.8.0 | 音频处理库 |
| Triton | 3.4.0 | PyTorch 性能优化 |
| ComfyUI | - | AI 图像生成工具 |
| SageAttention | 2.2.0 | 注意力机制优化 |
| FlashAttention | 2.8.3 | 注意力机制优化 |
| SAM2 | 1.0 | 图像分割模型 |

## 🚨 故障排除

- 如果 CUDA 不可用，检查 GPU 驱动是否正确安装
- 如果 PyTorch 安装失败，检查网络连接和磁盘空间
- 如果 ComfyUI 启动失败，检查依赖是否完整安装
- 如果 SageAttention 编译失败，确保已安装编译工具链
- 如果预编译 wheel 下载失败，脚本会自动回退到本地编译模式

## 🔄 GitHub Actions 自动编译

本项目使用 GitHub Actions 自动编译预编译的 wheel 包，以加速安装过程：

- **自动触发**：每次推送到 `master` 或 `main` 分支时自动触发
- **手动触发**：可以在 GitHub Actions 页面手动触发编译
- **编译产物**：编译好的 wheel 包会作为 Artifacts 保存 90 天
- **下载优先**：安装脚本会优先尝试下载预编译 wheel，失败时自动回退到本地编译

查看编译状态和下载产物：https://github.com/andangel/setup-wsl2-ubuntu/actions

## 📝 许可证

本项目基于原 setup-wsl2-ubuntu 项目修改，用于 ComfyUI 环境搭建。
