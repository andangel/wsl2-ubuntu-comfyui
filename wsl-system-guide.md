# WSL2 系统使用指南

本指南详细介绍 WSL2（Windows Subsystem for Linux 2）的高级使用技巧，包括跨文件系统、GPU 加速、网络代理、镜像管理和磁盘压缩等内容，帮助您更好地使用 WSL2 环境。

## 1. 跨文件系统

### 1.1 在 WSL 中访问 Windows 文件

WSL2 会自动将 Windows 驱动器挂载到 `/mnt` 目录下，您可以直接访问：

```bash
# 访问 C 盘
cd /mnt/c

# 访问 D 盘
cd /mnt/d
```

### 1.2 在 Windows 中访问 WSL 文件

您可以通过以下路径在 Windows 资源管理器中访问 WSL 文件：

```
\\wsl$\<分发版名称>\home\<用户名>
```

例如：

```
\\wsl$\Comfyui\home\ubuntu
```

### 1.3 性能优化

- **使用 WSL 本地文件系统**：对于需要频繁读写的操作，建议将文件放在 WSL 本地文件系统中（`/home/ubuntu` 目录），而不是 Windows 文件系统（`/mnt` 目录），这样可以获得更好的性能。
- **避免跨文件系统操作**：尽量避免在 WSL 和 Windows 文件系统之间进行大量文件复制或移动操作，这会导致性能下降。

### 1.4 AI 模型大文件存储建议

对于 AI 模型这种大文件的存储，有两种主要的访问方式：

#### 1.4.1 直接使用 `/mnt/` 目录访问

**优点**：
- 不需要额外配置，直接访问 Windows 文件系统中的模型文件
- 可以在 Windows 和 WSL 之间共享模型文件，避免重复存储
- 适合临时使用或不频繁访问的模型

**缺点**：
- 访问速度较慢，特别是对于需要频繁读写的场景
- 可能会遇到权限问题
- 跨文件系统操作可能导致性能下降

#### 1.4.2 使用链接方式访问

**优点**：
- 可以在 WSL 本地文件系统中创建链接，指向 Windows 文件系统中的模型文件
- 保持了 WSL 本地文件系统的访问速度
- 避免了跨文件系统操作的性能开销

**缺点**：
- 需要额外的配置步骤
- 链接可能会在 WSL 重启后失效

#### 1.4.3 推荐方案

对于 AI 模型这种大文件，建议采用以下方案：

1. **临时使用**：如果只是临时使用模型文件，可以直接通过 `/mnt/` 目录访问。

2. **频繁使用**：如果需要频繁访问模型文件，建议使用符号链接方式：

   ```bash
   # 在 WSL 中创建模型存储目录
   mkdir -p ~/models
   
   # 创建符号链接，指向 Windows 中的模型目录
   ln -s /mnt/d/models/ ~/models/windows-models
   ```

3. **长期使用**：对于需要长期使用的模型，建议将模型文件复制到 WSL 本地文件系统中：

   ```bash
   # 复制模型文件到 WSL 本地文件系统
   cp -r /mnt/d/models/my-model ~/models/
   ```

#### 1.4.4 效率比较

- **直接访问**：适合一次性或不频繁的访问，速度较慢
- **符号链接**：适合需要频繁访问但不想复制文件的场景，速度较快
- **本地复制**：适合需要最高性能的场景，速度最快，但会占用额外的磁盘空间

选择哪种方式取决于您的具体使用场景和对性能的要求。

### 1.5 限制 WSL2 对 Windows 驱动器的权限

默认情况下，WSL2 对 Windows 驱动器（如 C 盘）拥有读写权限。如果您希望限制 WSL2 对 C 盘只有读的权限，没有写与更改的权限，可以通过以下方法实现：

#### 1.5.1 修改 WSL 配置文件

1. **打开 WSL 配置文件**：
   - 在 Windows 中，打开 `%UserProfile%\.wslconfig` 文件

2. **添加挂载选项**：
   - 如果文件中已有 `[wsl2]` 部分，在该部分添加以下配置：

     ```ini
     [wsl2]
     # 其他配置...
     
     # 挂载选项
     automount.options="metadata,umask=222,fmask=111"
     ```
   
   - 如果文件中只有 `[experimental]` 部分，在文件顶部添加 `[wsl2]` 部分：

     ```ini
     [wsl2]
     # 挂载选项
     automount.options="metadata,umask=222,fmask=111"
     
     [experimental]
     # 现有配置...
     ```

   - 解释：
     - `umask=222`：设置文件权限掩码为 222，使得文件权限为 555（只读）
     - `fmask=111`：设置目录权限掩码为 111，使得目录权限为 666（但由于 umask 的作用，实际为 555）

#### 1.5.2 修改特定驱动器的挂载选项

如果您只想限制 C 盘的权限，而不影响其他驱动器，可以在 WSL 中手动挂载 C 盘：

1. **卸载当前的 C 盘挂载**：
   ```bash
   sudo umount /mnt/c
   ```

2. **重新挂载 C 盘，设置为只读**：
   ```bash
   sudo mount -t drvfs C: /mnt/c -o metadata,umask=222,fmask=111
   ```

#### 1.5.3 验证权限

1. **检查挂载选项**：
   ```bash
   mount | grep /mnt/c
   ```

2. **尝试创建文件**：
   ```bash
   echo "test" > /mnt/c/test.txt
   ```
   - 如果权限设置正确，应该会收到 "Permission denied" 错误

3. **尝试读取文件**：
   ```bash
   cat /mnt/c/Windows/System32/drivers/etc/hosts
   ```
   - 应该能够成功读取文件

#### 1.5.4 注意事项

- **重启 WSL**：修改 `wslconfig` 文件后，需要重启 WSL 实例才能生效：
  ```powershell
  wsl --terminate Comfyui
  ```

- **权限继承**：这些设置会影响所有通过 WSL 访问 Windows 驱动器的操作

- **安全性**：限制 WSL 对 Windows 驱动器的写权限可以提高系统安全性，防止 WSL 中的恶意程序修改 Windows 系统文件

- **灵活性**：如果需要临时获取写权限，可以使用 `sudo` 命令或重新挂载驱动器

#### 1.5.5 限制写权限的后果和影响

如果限制 WSL2 内的 Ubuntu 对 Windows 系统 C 盘的写权限，可能会产生以下影响：

1. **正面影响**：
   - **提高安全性**：防止 WSL 中的恶意程序修改 Windows 系统文件
   - **保护系统文件**：避免意外修改或删除 Windows 系统关键文件
   - **隔离环境**：增强 WSL 环境的隔离性，减少对 Windows 系统的影响

2. **可能的负面影响**：
   - **无法安装 Windows 路径的软件**：某些软件可能需要写入 C 盘才能完成安装
   - **无法修改 Windows 配置文件**：如果需要修改 Windows 系统的配置文件，可能会受到限制
   - **无法在 C 盘创建临时文件**：某些应用程序可能需要在 C 盘创建临时文件
   - **影响跨系统文件操作**：无法直接从 WSL 向 C 盘复制文件或修改 C 盘上的文件

3. **不受影响的功能**：
   - **读取 C 盘文件**：仍然可以正常读取 C 盘上的文件
   - **WSL 本地文件系统**：WSL 本地文件系统的读写操作不受影响
   - **其他驱动器**：如果只限制了 C 盘，其他驱动器（如 D 盘）的读写权限不受影响
   - **网络访问**：网络访问功能不受影响

4. **替代方案**：
   - **使用 D 盘**：将需要读写的文件放在 D 盘或其他非系统驱动器
   - **使用 WSL 本地文件系统**：将文件存储在 WSL 本地文件系统中
   - **临时挂载**：需要时临时重新挂载 C 盘为可写
   - **使用共享文件夹**：在 Windows 和 WSL 之间设置共享文件夹

#### 1.5.6 适用场景

限制 WSL2 对 C 盘的写权限适合以下场景：

- **安全性要求高**：对系统安全性有较高要求的环境
- **多用户环境**：多人使用同一台计算机的场景
- **生产环境**：用于生产部署的 WSL 实例
- **实验环境**：用于测试可能有风险的软件或代码

如果您只是个人使用 WSL 进行开发和学习，且对安全性要求不高，可能不需要限制 C 盘的写权限。

## 2. GPU 加速

### 2.1 WSL2 中的 GPU 支持

WSL2 支持 NVIDIA GPU 加速，允许您在 Linux 环境中使用 Windows 安装的 GPU 驱动程序进行 CUDA 计算。

### 2.2 CUDA 交互原理

**重要说明**：在 WSL2 中，您**不需要**安装 CUDA Toolkit 或 NVIDIA 驱动程序，因为 WSL2 会直接使用 Windows 系统安装的驱动程序。

#### 2.2.1 核心机制

- **WSL2 GPU 直通特性**：WSL2 可以直接访问 Windows 主机安装的 NVIDIA 驱动程序
- **透明 GPU 加速**：Windows 的 NVIDIA 驱动通过 WSL2 的 GPU 直通功能，让 Linux 应用直接使用 Windows GPU
- **可以直接使用 PyTorch 的 CUDA 版本**：不需要单独安装 CUDA Toolkit

#### 2.2.2 核心原理

- **PyTorch 自带 CUDA 运行时**：PyTorch 的 CUDA 版本已经包含了必要的 CUDA 运行时库
- **最小化依赖**：PyTorch 的 torch 包包含了 cuda_runtime、cudnn、cublas 等必要组件
- **工作原理**：WSL2 通过虚拟 GPU 架构，将 CUDA 调用从 Linux 环境转发到 Windows 系统的 NVIDIA 驱动程序

#### 2.2.3 版本兼容性

**Windows 显卡驱动的 CUDA 版本是否需要大于 WSL2 内 Ubuntu 的 PyTorch 内的 CUDA 版本？**

- **是的**：Windows 系统安装的 NVIDIA 驱动程序的 CUDA 版本应该大于或等于 PyTorch 中使用的 CUDA 版本
- **原因**：PyTorch 的 CUDA 运行时需要调用 Windows 驱动程序提供的 CUDA 功能
- **如何检查**：
  1. 在 Windows 中运行 `nvidia-smi` 查看驱动程序的 CUDA 版本
  2. 在 WSL2 中运行 `python -c "import torch; print(torch.version.cuda)"` 查看 PyTorch 的 CUDA 版本
- **最佳实践**：安装最新的 NVIDIA 驱动程序，以确保支持最新的 CUDA 版本

#### 2.2.4 安装要求

- **Windows 端**：需要安装最新的 NVIDIA 驱动程序（支持 WSL2 的版本）
- **WSL2 端**：
  - 对于运行 PyTorch 等预编译的 CUDA 应用：不需要安装 CUDA Toolkit
  - 对于编译 CUDA 代码：需要安装 CUDA Toolkit（用于编译，不用于运行）

### 2.3 验证 GPU 访问

在 WSL2 中运行以下命令验证 GPU 访问：

```bash
# 查看 GPU 信息（显示的是 Windows 系统的显卡驱动和 CUDA 版本）
nvidia-smi

# 检查 CUDA Toolkit 版本（WSL 中安装的版本）
nvcc --version
```

**说明**：`nvidia-smi` 命令显示的是 Windows 系统中安装的 NVIDIA 驱动程序版本和 CUDA 版本，而不是 WSL 中安装的 CUDA Toolkit 版本。这是因为 WSL2 直接使用 Windows 系统的 GPU 驱动程序。

### 2.4 编译 CUDA 代码

在 WSL2 中，您可以编译和运行 CUDA 代码，例如：

```bash
# 安装 CUDA Toolkit（如果需要）
sudo apt-get install cuda-toolkit-12-8

# 编译 CUDA 代码
nvcc -o hello hello.cu

# 运行 CUDA 程序
./hello
```

## 3. 网络代理

### 3.1 在 WSL2 中设置代理

如果您在 Windows 中使用代理服务器，可以在 WSL2 中设置相同的代理：

```bash
# 在 .bashrc 中添加代理设置
echo 'export http_proxy=http://<代理服务器IP>:<端口>' >> ~/.bashrc
echo 'export https_proxy=http://<代理服务器IP>:<端口>' >> ~/.bashrc

# 使设置生效
source ~/.bashrc
```

### 3.2 访问 Windows 本地服务

在 WSL2 中，您可以通过 `localhost` 访问 Windows 本地运行的服务：

```bash
# 访问 Windows 本地运行的 web 服务器
curl http://localhost:8080
```

### 3.3 网络配置

WSL2 使用虚拟网络适配器，与 Windows 系统共享网络连接。默认情况下，WSL2 会自动配置网络设置，无需手动配置。

## 4. 镜像管理

### 4.1 更改软件源

为了加快软件包下载速度，建议将 Ubuntu 软件源更改为国内镜像：

```bash
# 备份原始源文件
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

# 替换为国内镜像
sudo sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

# 更新软件包列表
sudo apt-get update
```

### 4.2 安装常用软件

```bash
# 安装常用工具
sudo apt-get install -y git wget curl build-essential

# 安装 Python 相关工具
sudo apt-get install -y python3 python3-pip python3-venv
```

## 5. 磁盘管理

### 5.1 压缩 WSL2 虚拟磁盘

WSL2 使用虚拟磁盘文件（VHDX）存储文件系统，随着使用，虚拟磁盘会逐渐增大，但不会自动缩小。您可以使用以下步骤压缩虚拟磁盘：

1. **停止 WSL 实例**：
   ```powershell
   wsl --terminate Comfyui
   ```

2. **使用 diskpart 压缩虚拟磁盘**：
   ```powershell
   diskpart
   # 在 diskpart 中执行以下命令
   select vdisk file="D:\WSL2\Comfyui\ext4.vhdx"
   attach vdisk readonly
   compact vdisk
   detach vdisk
   exit
   ```

### 5.2 查看磁盘使用情况

在 WSL2 中查看磁盘使用情况：

```bash
# 查看磁盘使用情况
df -h

# 查看目录大小
du -h --max-depth=1 /home/ubuntu
```

## 6. 高级配置

### 6.1 WSL 配置文件

WSL 配置文件位于 `%UserProfile%\.wslconfig`，您可以通过编辑此文件来配置 WSL2 的行为：

```ini
[wsl2]
# 内存限制
memory=8GB
# 处理器限制
processors=4
# 虚拟磁盘大小
swap=4GB
# 网络模式
networkingMode=nat
# 防火墙
firewall=true
# 自动挂载 Windows 驱动器
autoMount=true
```

### 6.2 分发版特定配置

每个 WSL 分发版都有自己的配置文件 `/etc/wsl.conf`：

```ini
[user]
# 默认用户
default=ubuntu

[network]
# 生成 /etc/resolv.conf
generateResolvConf=true

[automount]
# 自动挂载 Windows 驱动器
enabled=true
# 挂载点
root=/mnt/
# 挂载选项
options="metadata,umask=22,fmask=11"
```

### 6.3 使用 WSL Settings 进行全局配置

除了手动编辑配置文件外，您还可以使用 WSL Settings 图形界面进行全局配置，这是一种更简单直观的方式：

1. **打开 WSL Settings**：
   - 方法 1：在开始菜单中搜索 "适用于 Linux 的 Windows 子系统设置"
   - 方法 2：在 PowerShell 中运行 `wsl --settings` 命令

2. **配置选项**：
   - **内存和处理器**：设置 WSL 的内存限制、处理器数量和交换空间大小
   - **文件系统**：配置文件系统性能和自动挂载选项
   - **网络**：设置网络模式、端口转发和代理配置
   - **可选功能**：启用或禁用 WSL 的可选功能
   - **开发者**：配置开发相关的选项

3. **优点**：
   - 图形化界面，操作简单直观
   - 实时预览配置效果
   - 不需要手动编辑配置文件
   - 提供了更多高级选项

4. **注意事项**：
   - 某些高级配置可能仍然需要通过编辑配置文件来完成
   - 更改配置后，可能需要重启 WSL 实例才能生效

使用 WSL Settings 是配置 WSL 的推荐方式，特别是对于不熟悉命令行操作的用户来说，这是一个更加友好的选择。

### 6.3.1 .wslconfig 的作用范围

**`.wslconfig` 控制的是全局配置**，适用于系统中所有的 WSL2 实例。如果您的系统中有多个 WSL2 系统，`.wslconfig` 中的配置会应用到所有实例。

#### 为不同 WSL2 系统设置不同配置

如果您希望为不同的 WSL2 系统设置不同的配置，可以使用以下方法：

1. **使用分发版特定配置**：
   - 每个 WSL2 系统都有自己的配置文件 `/etc/wsl.conf`
   - 这个文件只影响特定的 WSL2 系统，不影响其他系统
   - 可以在这个文件中设置用户默认值、网络配置、自动挂载选项等

2. **使用 WSL Settings**：
   - 打开 WSL Settings
   - 在左侧导航栏中选择特定的 WSL2 系统
   - 为该系统设置特定的配置

3. **使用命令行参数**：
   - 在启动 WSL2 系统时，可以使用命令行参数指定特定的配置
   - 例如：`wsl --distribution Ubuntu-24.04 --memory 8GB --processors 4`

#### 配置优先级

配置的优先级从高到低依次是：
1. **命令行参数**：启动时指定的参数优先级最高
2. **分发版特定配置**：`/etc/wsl.conf` 文件中的配置
3. **全局配置**：`.wslconfig` 文件中的配置
4. **默认配置**：WSL2 的默认配置

### 6.4 内存回收模式

WSL2 提供了三种内存回收模式，用于管理 WSL 实例的内存使用：

#### 6.4.1 模式说明

1. **默认模式**：
   - WSL2 会根据需要自动管理内存
   - 当内存使用量超过阈值时，会尝试回收内存
   - 适用于大多数场景

2. **按需模式**：
   - 当 WSL2 检测到内存使用量低于阈值时，会立即回收内存
   - 内存回收更加积极，可能会影响性能
   - 适用于内存资源有限的系统

3. **手动模式**：
   - 需要用户手动触发内存回收
   - 内存使用更加可控
   - 适用于对内存使用有特殊要求的场景

#### 6.4.2 配置内存回收模式

您可以通过以下方式配置内存回收模式：

1. **使用 WSL Settings**：
   - 打开 WSL Settings
   - 进入 "内存和处理器" 选项卡
   - 在 "内存回收" 部分选择所需的模式

2. **编辑配置文件**：
   - 打开 `%UserProfile%\.wslconfig` 文件
   - 添加以下配置：

     ```ini
     [wsl2]
     # 内存回收模式：auto（默认）、on-demand（按需）、manual（手动）
     memoryRecycleMode=auto
     ```

### 6.5 AI 推理环境优化建议

在 WSL 虚拟环境下运行 AI 推理环境时，以下优化建议可以提高性能：

#### 6.5.1 内存配置

- **合理分配内存**：根据系统总内存和 AI 模型大小，为 WSL 分配足够的内存
  ```ini
  [wsl2]
  # 建议分配系统总内存的 50-70%
  memory=16GB
  # 交换空间大小
  swap=8GB
  ```

- **选择合适的内存回收模式**：
  - **对于 AI 推理环境**：建议使用 `auto` 模式（默认），避免频繁的内存回收影响性能
    ```ini
    [wsl2]
    memoryRecycleMode=auto
    ```
  - **对于内存资源有限的系统**：可以使用 `on-demand` 模式，但可能会影响性能
    ```ini
    [wsl2]
    memoryRecycleMode=on-demand
    ```
  - **对于需要精确控制内存的场景**：可以使用 `manual` 模式
    ```ini
    [wsl2]
    memoryRecycleMode=manual
    ```

  **说明**：对于 AI 推理环境，特别是大模型推理，`auto` 模式通常是更好的选择，因为它可以避免频繁的内存回收影响性能。`on-demand` 模式虽然可以更积极地回收内存，但可能会导致推理过程中的性能波动。选择哪种模式应该根据具体的硬件配置和使用场景来决定。

#### 6.5.2 GPU 加速

- **确保 GPU 驱动更新**：在 Windows 系统中安装最新的 NVIDIA 驱动程序
- **安装兼容的 CUDA Toolkit**：在 WSL 中安装与 Windows 驱动程序兼容的 CUDA Toolkit
- **使用 GPU 加速库**：优先使用支持 GPU 加速的库，如 PyTorch、TensorFlow 等

#### 6.5.3 文件系统优化

- **使用 WSL 本地文件系统**：将 AI 模型和数据存储在 WSL 本地文件系统中，提高访问速度
- **避免跨文件系统操作**：尽量减少在 WSL 和 Windows 文件系统之间的文件操作
- **使用符号链接**：对于需要共享的大文件，使用符号链接方式访问

#### 6.5.4 网络优化

- **启用 localhost 转发**：确保 WSL Settings 中启用了 localhost 转发，方便访问本地服务
- **配置网络代理**：如果需要访问外部资源，正确配置网络代理

#### 6.5.5 系统优化

- **更新 WSL**：保持 WSL 版本更新，获取最新的性能改进
- **限制后台进程**：关闭不需要的后台进程，释放系统资源
- **监控资源使用**：使用 `htop`、`nvidia-smi` 等工具监控系统资源使用情况

#### 6.5.6 具体建议

- **小模型推理**：可以直接在 WSL 中运行，无需特殊配置
- **中模型推理**：建议分配 16-32GB 内存，使用 WSL 本地文件系统
- **大模型推理**：建议分配 32GB 以上内存，考虑使用量化技术减少内存使用

## 7. 故障排除

### 7.1 常见问题及解决方案

- **GPU 不可用**：确保 Windows 已安装最新的 NVIDIA 驱动程序，并且 WSL2 版本已更新
- **网络连接问题**：检查 Windows 防火墙设置，确保 WSL2 网络连接未被阻止
- **磁盘空间不足**：使用磁盘压缩功能减小虚拟磁盘大小，或增加 WSL2 的磁盘配额
- **CUDA 编译错误**：确保安装了与 Windows 驱动程序兼容的 CUDA Toolkit 版本

### 7.2 查看 WSL 日志

```powershell
# 查看 WSL 日志
Get-EventLog -LogName Application -Source "Wsl*" -Newest 20
```

## 8. 最佳实践

- **定期备份**：使用 `wsl --export` 命令定期备份 WSL 实例
- **保持更新**：定期更新 WSL2 和 Windows 系统，以获得最新的功能和修复
- **合理分配资源**：根据系统配置调整 WSL2 的内存和处理器限制
- **使用 WSL 本地文件系统**：对于性能敏感的应用，使用 WSL 本地文件系统
- **避免频繁跨文件系统操作**：减少在 WSL 和 Windows 文件系统之间的文件操作

## 9. 参考资源

- [Microsoft WSL 文档](https://learn.microsoft.com/en-us/windows/wsl/)
- [NVIDIA WSL 支持](https://developer.nvidia.com/cuda/wsl)
- [Ubuntu WSL 文档](https://ubuntu.com/wsl)

本指南基于 Microsoft 官方文档和实际使用经验编写，旨在为普通用户提供清晰易懂的 WSL2 使用指南。