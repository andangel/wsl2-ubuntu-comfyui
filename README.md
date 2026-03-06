# Ubuntu 24.04 (WSL2) ComfyUI 环境初始化脚本

这是一个用于快速配置 Ubuntu 24.04 (WSL2) ComfyUI AI 图像生成环境的 Shell 脚本套件。它集成了国内高速镜像源（清华大学开源软件镜像站），并自动化安装 CUDA、PyTorch、ComfyUI 等 AI 开发工具，旨在提供开箱即用的 ComfyUI 开发体验。

## ✨ 特性

- **Windows 一键部署**：提供 PowerShell 交互式向导，双击即可部署 WSL2 + ComfyUI 完整环境。
- **国内加速**：APT、Conda、PyTorch 等均默认配置清华/国内镜像源，大幅提升下载速度。
- **模块化设计**：支持一键全量安装，也支持按需单独配置特定组件。
- **幂等性**：内置状态检查，重复运行会提示确认，避免误覆盖现有配置。
- **AI 工具链集成**：
    - **基础依赖**: 自动安装 unzip、build-essential 等常用工具。
    - **Python**: Miniconda3 (使用 base 环境，Python 3.12)
    - **PyTorch**: 安装 PyTorch 2.8.0 (CUDA 12.8 版本)
    - **ComfyUI**: 自动克隆并安装 ComfyUI 及其依赖
    - **CUDA Toolkit**: 手动安装 (运行 `./main.sh --cudatoolkit`)
    - **SageAttention**: 手动安装 (运行 `./main.sh --sageattention`)
    - **FlashAttention**: 手动安装 (运行 `./main.sh --flashattention`)
    - **SAM2**: 手动安装 (运行 `./main.sh --sam2`)
    - **Triton**: 自动安装 Triton 3.4.0 性能优化库
    - **GitHub Actions**: 自动编译预编译 wheel 包，加速安装过程
- **WSL2 配置优化**：提供配置检查和推荐工具，根据硬件自动优化 WSL2 性能。

## 🖥 WSL2 基础系统初始化

在使用本脚本之前，需要先创建 WSL2 基础系统。我们提供了两种方式：

### 方式一：PowerShell 一键部署（推荐）

双击运行 `wsl_scripts/Run-Install-ComfyUI.bat`，或使用 PowerShell：

```powershell
# 交互式向导（推荐）
.\wsl_scripts\Install-ComfyUI.ps1

# 或指定所有参数
.\wsl_scripts\Install-ComfyUI.ps1 `
    -InstanceName "Comfyui" `
    -InstallTarPath "C:\Downloads\install.tar.gz" `
    -WSLPath "D:\WSL2" `
    -ProjectUrl "https://github.com/andangel/wsl2-ubuntu-comfyui.git" `
    -InstallOption "--all"
```

**交互式向导会提示：**
- WSL 实例名称（默认: Comfyui）
- install.tar.gz 路径（默认: 用户下载目录）
- WSL 安装盘符（默认: D:，自动创建 D:\WSL2）
- 项目仓库地址
- 安装选项

### 方式二：手动创建

详细步骤请参考 [docs/init-wsl2-ubuntu.md](docs/init-wsl2-ubuntu.md) 文件。

### WSL2 配置优化工具

我们还提供了 WSL2 配置检查和优化工具：

| 工具 | 启动方式 | 功能 |
|------|---------|------|
| WSL2 需求检查 | 双击 `Run-WSL2-Check.bat` | 检查系统是否满足 WSL2 要求 |
| WSL 配置推荐 | 双击 `Run-WSL-Config-Recommend.bat` | 根据硬件推荐最优配置 |

## 🚀 快速开始

### 完整流程

1.  **克隆项目**
    ```bash
    git clone https://github.com/andangel/wsl2-ubuntu-comfyui.git
    cd wsl2-ubuntu-comfyui
    ```

2.  **赋予执行权限**
    ```bash
    chmod +x main.sh scripts/*.sh
    ```

3.  **一键配置基础环境** (推荐)
    这会安装：Ubuntu 24.04 APT 镜像源、基础依赖、Miniconda、PyTorch、ComfyUI 及编译依赖
    ```bash
    ./main.sh --all
    ```
    
## 📖 使用指南

### 常用命令选项

| 功能 | 命令 | 说明 |
| :--- | :--- | :--- |
| **全量配置** | `./main.sh --all` | 执行所有初始化任务 |
| **APT 换源** | `./main.sh --apt` | 备份原源，替换为清华源并更新缓存 |
| **基础依赖** | `./main.sh --deps` | 安装 unzip、build-essential 等基础工具 |
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
├── docs/                   # 文档目录
│   ├── CLAUDE.md           # 项目上下文与开发规范文档
│   ├── init-wsl2-ubuntu.md # WSL2 基础系统初始化指南
│   └── wsl-system-guide.md # WSL2 系统配置详细指南
├── lib/
│   └── utils.sh            # 通用工具库（日志、颜色、交互确认）
├── scripts/                # 独立组件安装脚本
│   ├── setup_apt.sh        # APT 软件源配置
│   ├── install_deps.sh     # 基础依赖安装
│   ├── setup_miniconda.sh  # Miniconda 安装
│   ├── setup_cudatoolkit.sh# CUDA Toolkit 安装
│   ├── setup_pytorch.sh    # PyTorch 安装
│   ├── setup_comfyui.sh    # ComfyUI 安装
│   ├── setup_sageattention.sh   # SageAttention 安装
│   ├── setup_flashattention.sh  # FlashAttention 安装
│   ├── setup_sam2.sh       # SAM2 安装
│   ├── diagnose.sh         # 环境诊断脚本
│   ├── update-github-hosts.sh   # GitHub  hosts 更新
│   ├── build_flashattention.sh  # 编译 FlashAttention
│   ├── build_sageattention.sh   # 编译 SageAttention
│   └── build_sam2.sh       # 编译 SAM2
├── update/                 # ComfyUI 更新脚本目录
│   ├── update_comfyui.sh        # 更新到最新版本
│   ├── update_comfyui_stable.sh # 更新到稳定版本
│   ├── update_comfyui_and_python_dependencies.sh
│   ├── update.py
│   └── current_requirements.txt
├── wsl_scripts/            # Windows PowerShell 脚本
│   ├── Install-ComfyUI.ps1           # WSL2 部署脚本（交互式向导）
│   ├── Run-Install-ComfyUI.bat       # 部署脚本启动器
│   ├── Check-WSL2-Requirements.ps1   # WSL2 需求检查
│   ├── Run-WSL2-Check.bat            # 检查工具启动器
│   ├── Recommend-WSL-Config.ps1      # WSL 配置推荐
│   ├── Run-WSL-Config-Recommend.bat  # 配置推荐启动器
│   └── .wslconfig.template           # WSL 配置模板
├── test/                   # 测试脚本目录
│   ├── test_flashattention.py
│   └── test_sageattention.py
├── image/                  # 项目架构图
└── .github/workflows/      # GitHub Actions
    └── build-wheels.yml    # 自动编译 wheel 包
```

## ⚠️ 注意事项

1.  **Windows 部署**：使用 `Run-Install-ComfyUI.bat` 部署前，请确保已下载 `install.tar.gz`（Ubuntu 24.04 根文件系统）。
2.  **WSL2 配置**：建议在部署后运行 `Run-WSL-Config-Recommend.bat` 优化 WSL2 配置，以获得最佳性能。
3.  **Shell 自动刷新**：ComfyUI 安装脚本执行完毕后会自动重新加载 shell，别名立即生效，无需手动操作。
4.  **CUDA 安装**：CUDA Toolkit 12.8 安装需要较长时间，请耐心等待。
5.  **预编译 Wheel**：脚本会优先从 GitHub Releases 下载预编译的 wheel 包（SageAttention、FlashAttention、SAM2），如果下载失败则会自动进行本地编译。
6.  **本地编译**：如果预编译 wheel 不可用，脚本会自动进行本地编译，确保已安装 `build-essential`、`gcc`、`g++`、`make` 等编译工具。
7.  **GPU 要求**：本环境需要 NVIDIA GPU 支持，建议显存 >= 8GB。
8.  **更新脚本**：`~/update/` 目录包含 ComfyUI 更新脚本，可使用 `comfyui-update` 别名快速更新。

## 🎯 启动 ComfyUI

安装完成后，可以使用以下方式启动 ComfyUI：

### Shell 别名（推荐）

安装完成后会自动添加以下别名到 `~/.bashrc`：

| 别名 | 命令 | 说明 |
|------|------|------|
| `comfyui` | `bash ~/run_nvidia_gpu.sh` | 启动 ComfyUI (GPU 模式) |
| `comfyui-update` | `bash ~/update/update_comfyui_stable.sh` | 更新 ComfyUI 到稳定版本 |

使用别名启动：
```bash
comfyui
```

### 直接启动

- **使用 GPU 启动**：
    ```bash
    bash ~/run_nvidia_gpu.sh
    ```
- **使用 CPU 启动**：
    ```bash
    bash ~/run_cpu.sh
    ```

### 访问 ComfyUI

- 在 Windows 浏览器中访问：http://localhost:8188



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

查看编译状态和下载产物：https://github.com/andangel/wsl2-ubuntu-comfyui/actions

## 📝 许可证

本项目基于原 setup-wsl2-ubuntu 项目修改，用于 ComfyUI 环境搭建。