# CLAUDE.md - 项目上下文与开发指南

## 项目概览
本项目提供了一套模块化、灵活的 Shell 脚本套件 (`setup-wsl2-ubuntu`)，用于初始化和配置 Ubuntu 22.04 本地开发环境（针对 WSL2 进行了优化）。它自动化安装常用的开发工具，并为国内用户配置了高速镜像源（清华大学开源软件镜像站）。

## 常用指令
- **执行所有配置任务**: `./main.sh --all`
- **显示帮助信息**: `./main.sh --help`
- **配置特定组件**:
  - APT 镜像源: `./main.sh --apt`
  - 基础依赖: `./main.sh --deps` (unzip, proxychains4)
  - WSL 配置: `./main.sh --wsl` (systemd, interop)
  - Git 客户端: `./main.sh --git` (需先配置 `git.config`)
  - SSH 服务端 (自定义端口): `./main.sh --ssh-server <port>` (Supervisor 管理, 默认端口: 8022)
  - SSH 客户端密钥: `./main.sh --ssh-client`
  - Miniconda (Python 3.13): `./main.sh --conda`
  - Node.js (LTS, 通过 fnm): `./main.sh --node`
  - Rust (通过 rustup): `./main.sh --rust`
  - Go (通过 g): `./main.sh --go`

## 项目结构
- `main.sh`: 主入口脚本。负责解析参数并调用具体的子脚本。
- `config.sh`: 集中化配置文件（版本号、镜像源 URL、端口配置等）。
- `lib/utils.sh`: 通用工具库，包含日志打印、颜色输出和用户确认函数 (`check_and_confirm`)。
- `git.config.example`: Git 客户端配置模板，用户需复制为 `git.config` 并填入个人信息后使用。
- `scripts/`: 独立组件的安装/配置脚本。
  - `setup_apt.sh`: APT 软件源配置。
  - `install_deps.sh`: 基础依赖安装 (unzip, proxychains4)。
  - `setup_wsl.sh`: WSL 基础配置 (/etc/wsl.conf)。
  - `setup_git.sh`: Git 客户端配置（含参数验证）。
  - `setup_ssh_server.sh`: OpenSSH 服务端配置。
  - `setup_ssh_client.sh`: 生成 Ed25519 密钥对。
  - `setup_miniconda.sh`: Miniconda 安装及环境创建。
  - `setup_node.sh`: 使用 `fnm` 配置 Node.js 环境。
  - `setup_rust.sh`: 使用 `rustup` 配置 Rust 环境。
  - `setup_go.sh`: 使用 `g` (voidint/g) 配置 Go 环境。

## 开发规范
- **语言**: Bash Shell 脚本 (`#!/bin/bash`)。
- **模块化**: 组件逻辑必须隔离在 `scripts/` 目录下。使用 `main.sh` 进行编排。
- **幂等性**: 所有脚本必须具备幂等性。在覆盖配置前，必须使用 `lib/utils.sh` 中的 `check_and_confirm` 函数检查组件状态并征求用户确认。
- **配置管理**: 禁止硬编码（如 URL、版本号）。所有配置项必须在 `config.sh` 中定义。
- **镜像源**: 下载和注册表配置必须默认使用 **清华大学开源软件镜像站** (`mirrors.tuna.tsinghua.edu.cn`) 以确保国内访问速度。
- **网络健壮性**: 禁止使用 `curl ... | bash` 直接管道执行远程脚本。必须先将脚本下载到本地临时文件，检查下载状态（失败需调用 `handle_net_error` 报错并退出），确认成功后再执行。
- **错误处理**: 脚本中应使用 `set -e`，确保遇到错误立即停止。
- **日志**: 使用 `lib/utils.sh` 提供的 `log_info`, `log_success`, `log_warn`, `log_error` 函数进行输出。所有用户提示信息应使用**简体中文**。

## 工具细节
- **Python**: 使用 Miniconda3，默认创建一个名为 `dev` 的环境，Python 版本为 3.13。
- **Node.js**: 使用 `fnm` (Fast Node Manager) 进行版本管理。
- **Go**: 使用 `g` (voidint/g) 进行版本管理（轻量级、二进制分发）。
- **Rust**: 使用 `rustup` 和 `cargo`，并配置 crates.io 镜像源。
- **Git**: 复制本地模板配置，强制校验用户信息完整性。
- **SSH**: 
  - 服务端: 使用 Supervisor 托管，默认监听 8022 端口。
  - 客户端: 生成 `ed25519` 类型的密钥对。
- **WSL**: 配置启用 systemd，禁用 Windows PATH 自动追加。
