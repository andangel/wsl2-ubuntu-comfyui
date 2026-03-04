# Ubuntu 24.04 LTS 安装与部署

在使用本脚本之前，需要先创建 WSL2 基础系统。以下是完整的初始化步骤：

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
wsl -d Comfyui -u root -e usermod -aG sudo ubuntu
```

### 3.2 默认让 ubuntu 用户登录

```powershell
wsl -u root -e sh -c "echo '[user]' >> /etc/wsl.conf && echo 'default=ubuntu' >> /etc/wsl.conf"
```

### 3.3 重启 WSL 生效

```powershell
wsl --terminate Comfyui
```

### 3.4 克隆项目

在开始菜单应该能看到名为 Comfyui 的快捷方式，点击进入 WSL 系统后执行以下命令：

```bash
git clone https://github.com/andangel/wsl2-ubuntu-comfyui.git
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