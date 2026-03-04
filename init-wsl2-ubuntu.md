# 同时安装与使用多个 Ubuntu 22.04 LTS 镜像

1. 下载 Ubuntu 22.04 LTS 

- Ubuntu 22.04 LTS (Jammy Jellyfish) 服务器版镜像下载链接：[64 位 AMD/Intel 服务器版（cloud image）](https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64-root.tar.xz)
- 中国传媒大学校内分享名称：Linux系统与网络管理-课程公开分享 分享链接：https://kod.cuc.edu.cn/#s/9BGcMgPw 访问密码：sumw2
  
  
2. 准备工作

```powershell
mkdir d:\WSL\untu-22.04-Dev
```

3. 导入并创建新的 WSL 实例

确保下载的镜像文件 `ubuntu-22.04-server-cloudimg-amd64-root.tar.xz` 位于当前目录下，执行以下命令：

```powershell
wsl --import Ubuntu-22.04-Dev D:\WSL\untu-22.04-Dev ubuntu-22.04-server-cloudimg-amd64-root.tar.xz --version 2
```

4. 启动实例并完成初始化

```powershell
# 1. 启动新实例
wsl -d Ubuntu-22.04-Dev

# 2. 进入实例后，由于是 rootfs 导入，默认以 root 用户登录。
# 你可以选择直接使用 root 用户，但为了隔离和安全性，建议创建一个新普通用户。

# 3. 创建新的独立用户（例如，用户名为 cuc）
adduser cuc
# 按照提示设置新用户的密码和相关信息

# 4. 将新用户添加到 sudo 组，以获得管理员权限
usermod -aG sudo cuc

# 5. （可选但推荐）设置该用户为默认登录用户
# 退出实例回到 Windows 终端
exit

# 在 Windows 终端中，为这个新实例创建 WSL 配置文件
# 注意：以下命令中的路径需要使用实例内的 Linux 路径格式
wsl -d Ubuntu-22.04-Dev -u root bash -c "echo -e '[user]
default=cuc' > /etc/wsl.conf"

# 6. 关闭该实例，使配置生效
wsl --terminate Ubuntu-22.04-Dev

# 7. 重新启动实例，此时应默认以 devuser 用户登录
wsl -d Ubuntu-22.04-Dev
```

5. 验证安装

```powershell
wsl --list --verbose
```

