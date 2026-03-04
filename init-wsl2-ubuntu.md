# WSL2 基础系统初始化指南

本指南用于在 Windows 上创建和配置 WSL2 Ubuntu 24.04 基础系统。

## 📋 初始化步骤

### 1. 目录创建

```powershell
mkdir D:\Backup -Force
mkdir D:\WSL2\Comfyui -Force
```

### 2. 下载 Ubuntu 24.04 基础系统

**下载地址**：
```
https://wslstorestorage.blob.core.windows.net/wslblob/Ubuntu2404-240425.AppxBundle
```

**下载并重命名**：
```powershell
# 下载并重命名为 ZIP 格式
Invoke-WebRequest -Uri "https://wslstorestorage.blob.core.windows.net/wslblob/Ubuntu2404-240425.AppxBundle" -OutFile "D:\Backup\Ubuntu2404-240425.zip"
```

### 3. 解压基础系统

```powershell
# 解压 Ubuntu2404-240425.zip 文件
Expand-Archive -LiteralPath "D:\Backup\Ubuntu2404-240425.zip" -DestinationPath "D:\Backup"
```

### 4. 导入基础系统

```powershell
# 导入到 WSL2
wsl --import Ubuntu2404 "D:\WSL2\Comfyui" "D:\Backup\Ubuntu2404-240425\install.tar.gz" --version 2
```

**说明**：
- `install.tar.gz` 就是基础系统的压缩包
- 包含完整的 Ubuntu 24.04 系统文件
- 使用 `--version 2` 参数导入

### 5. 首次登录与用户配置

#### 5.1 以 root 身份首次登录

```powershell
wsl -d Ubuntu2404
```

#### 5.2 执行 WSL2 基础系统初始化脚本

```bash
cd /path/to/setup-wsl2-ubuntu
sudo bash scripts/init_wsl_base.sh
```

**注意**：此脚本需要以 root 身份在 WSL 内部执行。

**脚本会自动完成以下操作**：
- ✅ 授予 ubuntu 用户 sudo 权限
- ✅ 配置默认登录用户为 ubuntu
- ✅ 配置安全设置（systemd、禁用自动挂载、禁用 Windows PATH）
- ✅ 配置 fstab（只映射 E 盘到 /mnt/e）
- ✅ 创建挂载点
- ✅ 清理历史记录

#### 5.3 终止 WSL 实例

```powershell
wsl --terminate Ubuntu2404
```

#### 5.4 重新登录验证

```powershell
wsl -d Ubuntu2404
```

#### 5.5 测试 ubuntu 用户权限

```bash
sudo apt update
sudo apt upgrade
```

### 6. 克隆项目

```bash
git clone https://github.com/andangel/wsl2-ubuntu-comfyui.git
cd wsl2-ubuntu-comfyui
```

## 📝 后续步骤

基础系统初始化完成后，可以运行主脚本进行环境配置：

```bash
chmod +x main.sh scripts/*.sh
./main.sh --all
```

## 🎯 初始化完成

WSL2 基础系统初始化完成！现在可以开始配置 ComfyUI 环境。