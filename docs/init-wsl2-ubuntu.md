# Ubuntu 24.04 LTS 安装与部署

在使用本脚本之前，需要先创建 WSL2 基础系统。以下是完整的初始化步骤：

## 0. 先决条件

### 0.1 系统要求

| 项目 | 最低要求 |
|------|----------|
| Windows 版本 | Windows 10 2004+ (Build 19041) 或 Windows 11 |
| CPU | 支持虚拟化 |
| 内存 | 16 GB 以上（推荐 32 GB） |
| 磁盘 | 50 GB 以上可用空间 |
| GPU | NVIDIA 显卡（如需 AI 加速） |

### 0.2 启用 WSL2 功能

以**管理员身份**打开 PowerShell，执行：

```powershell
wsl --install
```

此命令会自动：
- 启用 WSL 和虚拟机平台功能
- 下载并安装 WSL2 Linux 内核
- 将 WSL2 设为默认版本

安装完成后**重启电脑**。

### 0.3 安装 NVIDIA 驱动（GPU 用户）

如需使用 GPU 加速，请安装支持 WSL 的 NVIDIA 驱动：

1. 访问 [NVIDIA 驱动下载页面](https://www.nvidia.com/Download/index.aspx)
2. 选择您的显卡型号
3. 下载并安装驱动（版本需 >= 470.76）

**验证驱动安装**：
```powershell
nvidia-smi
```

应显示 GPU 信息和驱动版本。

## 1. 目录创建

```powershell
mkdir D:\Backup -Force
mkdir D:\WSL2\ -Force
```

## 2. 导入基础系统

### 2.1 下载 Ubuntu 24.04 基础系统

[Ubuntu 24.04 下载地址](https://wslstorestorage.blob.core.windows.net/wslblob/Ubuntu2404-240425.AppxBundle)

将下载的 AppxBundle 文件重命名为 ZIP 格式：

```powershell
Rename-Item -Path Ubuntu2404-240425.AppxBundle -NewName Ubuntu2404-240425.zip
```

解压 Ubuntu2404-240425.zip 文件：

```powershell
Expand-Archive -Path Ubuntu2404-240425.zip -DestinationPath D:\WSL2\Ubuntu2404-240425
```

进入 Ubuntu2404-240425 文件夹：

```powershell
cd Ubuntu2404-240425
```

将 Ubuntu_2404.0.5.0_x64.appx 文件重命名为 Ubuntu_2404.0.5.0_x64.zip：

```powershell
Rename-Item -Path Ubuntu_2404.0.5.0_x64.appx -NewName Ubuntu_2404.0.5.0_x64.zip
```

解压 Ubuntu_2404.0.5.0_x64.zip 文件：

```powershell
Expand-Archive -Path Ubuntu_2404.0.5.0_x64.zip -DestinationPath D:\WSL2\Ubuntu2404-240425\Ubuntu_2404.0.5.0_x64
```

进入 Ubuntu_2404.0.5.0_x64 文件夹：

```powershell
cd Ubuntu_2404.0.5.0_x64
```

将 Ubuntu_2404.0.5.0_x64 文件夹中的 install.tar.gz 复制到 D:\Backup 文件夹：

```powershell
Copy-Item -Path install.tar.gz -Destination "D:\Backup"
```

删除 D:\WSL2\Ubuntu2404-240425 文件夹：

```powershell
Remove-Item -Path D:\WSL2\Ubuntu2404-240425 -Recurse -Force
```

### 2.2 使用 install.tar.gz 导入（如果您已有）

```powershell
wsl --import Comfyui "D:\WSL2\Comfyui" "D:\Backup\install.tar.gz" --version 2
```

**说明**：
- `install.tar.gz` 就是基础系统的压缩包
- 包含完整的 Ubuntu 24.04 系统文件
- 使用 `--version 2` 参数导入

## 3. 首次登录与用户配置

### 3.1 给 ubuntu 用户添加 sudo 权限

```powershell
wsl -d Comfyui -u root usermod -aG sudo ubuntu
```

### 3.2 默认让 ubuntu 用户登录

```powershell
wsl -d Comfyui -u root -e bash -c "echo '[user]' >> /etc/wsl.conf"
wsl -d Comfyui -u root -e bash -c "echo 'default=ubuntu' >> /etc/wsl.conf"
```

### 3.3 重启 WSL 生效

```powershell
wsl --terminate Comfyui
```

### 3.4 克隆项目

在开始菜单应该能看到名为 Comfyui 的快捷方式，点击进入 WSL 系统后执行以下命令：

**GitHub（国外用户）**：
```bash
git clone https://github.com/andangel/wsl2-ubuntu-comfyui.git
```

**Gitee（国内用户）**：
```bash
git clone https://gitee.com/andangel/wsl2-ubuntu-comfyui.git
```

进入项目目录：
```bash
cd wsl2-ubuntu-comfyui
```

## 4. WSL管理命令

查看 WSL 实例列表：

```powershell
wsl --list --verbose
```

备份 Comfyui WSL 实例：

```powershell
wsl --export Comfyui "D:\Backup\Comfyui-240425.tar.gz"
```

停止 Comfyui WSL 实例：

```powershell
wsl --terminate Comfyui
```

删除 Comfyui WSL 实例：

```powershell
wsl --unregister Comfyui
```

重新导入 Comfyui WSL 实例：

```powershell
wsl --import Comfyui "D:\WSL2\Comfyui" "Comfyui-240425.tar.gz" --version 2
```

## 5. 常见问题

### 5.1 WSL 导入失败

**问题**：`wsl --import` 报错 "指定的文件无法解压"

**解决方案**：
1. 确认 `install.tar.gz` 文件完整，大小约 600MB
2. 确认目标路径存在：`mkdir D:\WSL2\Comfyui -Force`
3. 以管理员身份运行 PowerShell

### 5.2 无法访问 GitHub

**问题**：克隆项目时超时或连接失败

**解决方案**：
使用 Gitee 镜像：
```bash
git clone https://gitee.com/andangel/wsl2-ubuntu-comfyui.git
```

### 5.3 GPU 不可用

**问题**：`nvidia-smi` 在 WSL 中无法运行

**解决方案**：
1. 确认 Windows 端 NVIDIA 驱动已安装（版本 >= 470.76）
2. 确认驱动支持 WSL（非 Game Ready 驱动可能有问题）
3. 重启 WSL：`wsl --shutdown` 后重新进入

**验证**：
```bash
nvidia-smi
```

### 5.4 内存不足

**问题**：WSL 占用过多内存导致系统卡顿

**解决方案**：

创建 `%USERPROFILE%\.wslconfig` 文件：
```ini
[wsl2]
memory=8GB
processors=4
swap=2GB
```

重启 WSL 生效：
```powershell
wsl --shutdown
```

### 5.5 磁盘空间不足

**问题**：VHDX 文件过大

**解决方案**：

压缩 VHDX 文件（需先关闭 WSL）：
```powershell
wsl --shutdown
optimize-vhd -Path "D:\WSL2\Comfyui\ext4.vhdx" -Mode Full
```

如 `optimize-vhd` 不可用，使用 `diskpart`：
```powershell
diskpart
select vdisk file="D:\WSL2\Comfyui\ext4.vhdx"
compact vdisk
exit
```

### 5.6 网络代理问题

**问题**：需要使用代理访问外网

**解决方案**：

在 WSL 中设置代理（假设 Windows IP 为 `172.x.x.1`）：
```bash
export http_proxy="http://172.x.x.1:7890"
export https_proxy="http://172.x.x.1:7890"
```

获取 Windows 主机 IP：
```bash
cat /etc/resolv.conf | grep nameserver | awk '{print $2}'
```

### 5.7 权限问题

**问题**：`sudo: unable to resolve host`

**解决方案**：
```bash
echo "127.0.0.1 localhost $(hostname)" | sudo tee -a /etc/hosts
```

### 5.8 项目脚本执行失败

**问题**：运行 `./main.sh` 报错

**解决方案**：
1. 确认脚本有执行权限：`chmod +x main.sh`
2. 运行诊断工具：`./main.sh --diagnose`
3. 检查日志输出，按提示修复