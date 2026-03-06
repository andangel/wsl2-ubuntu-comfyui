# ╔════════════════════════════════════════════════════════════════╗
# ║   ComfyUI 部署脚本                                           ║
# ║   ComfyUI Deployment Script                                  ║
# ║   Version: 1.1.0                                             ║
# ╚════════════════════════════════════════════════════════════════╝

param(
    [Parameter(Mandatory = $false)]
    [string]$InstanceName = '',
    
    [Parameter(Mandatory = $false)]
    [string]$InstallTarPath = '',
    
    [Parameter(Mandatory = $false)]
    [string]$WSLPath = '',
    
    [Parameter(Mandatory = $false)]
    [string]$ProjectUrl = '',
    
    [Parameter(Mandatory = $false)]
    [string]$InstallOption = ''
)

# 默认值
$DefaultInstanceName = 'Comfyui'
$DefaultInstallTarPath = "$env:USERPROFILE\Downloads\install.tar.gz"
$DefaultWSLDrive = 'D:'
$DefaultProjectUrl = 'https://github.com/andangel/wsl2-ubuntu-comfyui.git'
$DefaultInstallOption = '--all'

# WSL2 固定目录名
$WSLFolderName = 'WSL2'

# 交互式向导函数
function Get-UserInputWithDefault {
    param(
        [string]$Prompt,
        [string]$DefaultValue,
        [switch]$IsPath
    )
    
    Write-Host "$Prompt " -ForegroundColor Cyan -NoNewline
    Write-Host "[默认: $DefaultValue]" -ForegroundColor DarkGray -NoNewline
    Write-Host ": " -ForegroundColor Cyan -NoNewline
    
    $userInput = Read-Host
    
    if ([string]::IsNullOrWhiteSpace($userInput)) {
        return $DefaultValue
    }
    
    # 路径规范化
    if ($IsPath) {
        return $userInput.Trim().TrimEnd('"')
    }
    
    return $userInput.Trim()
}

# 显示向导
Write-Host "`n===========================================" -ForegroundColor Green
Write-Host "        ComfyUI 部署脚本" -ForegroundColor Green
Write-Host "        交互式配置向导" -ForegroundColor Green
Write-Host "===========================================`n" -ForegroundColor Green

# 检查是否需要启动完整向导模式（任一参数为空则启动向导）
$needWizard = [string]::IsNullOrWhiteSpace($InstanceName) -or
              [string]::IsNullOrWhiteSpace($InstallTarPath) -or
              [string]::IsNullOrWhiteSpace($WSLPath) -or
              [string]::IsNullOrWhiteSpace($ProjectUrl) -or
              [string]::IsNullOrWhiteSpace($InstallOption)

if ($needWizard) {
    Write-Host "请配置部署参数（直接回车使用默认值）：`n" -ForegroundColor Yellow

    # 获取用户输入
    $InstanceName = Get-UserInputWithDefault -Prompt "WSL 实例名称" -DefaultValue $(if ($InstanceName) { $InstanceName } else { $DefaultInstanceName })
    $InstallTarPath = Get-UserInputWithDefault -Prompt "install.tar.gz 路径" -DefaultValue $(if ($InstallTarPath) { $InstallTarPath } else { $DefaultInstallTarPath }) -IsPath
    
    # WSL 安装盘符（自动添加 WSL2 目录）
    $wslDrive = Get-UserInputWithDefault -Prompt "WSL 安装盘符" -DefaultValue $(if ($WSLPath) { $WSLPath.Substring(0, 2) } else { $DefaultWSLDrive })
    # 确保格式为 X:
    $wslDrive = $wslDrive.Trim().TrimEnd('\')
    if (-not $wslDrive.EndsWith(':')) {
        $wslDrive = "$wslDrive`:"
    }
    $WSLPath = "$wslDrive\$WSLFolderName"
    
    $ProjectUrl = Get-UserInputWithDefault -Prompt "项目仓库地址" -DefaultValue $(if ($ProjectUrl) { $ProjectUrl } else { $DefaultProjectUrl })
    $InstallOption = Get-UserInputWithDefault -Prompt "安装选项" -DefaultValue $(if ($InstallOption) { $InstallOption } else { $DefaultInstallOption })
} else {
    Write-Host "检测到所有参数已通过命令行指定，跳过交互式向导。`n" -ForegroundColor DarkGray
}

# 显示配置摘要
Write-Host "`n===========================================" -ForegroundColor Green
Write-Host "        配置摘要" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
Write-Host "  实例名称: $InstanceName" -ForegroundColor White
Write-Host "  Tar 路径: $InstallTarPath" -ForegroundColor White
Write-Host "  WSL 目录: $WSLPath" -ForegroundColor White
Write-Host "  项目地址: $ProjectUrl" -ForegroundColor White
Write-Host "  安装选项: $InstallOption" -ForegroundColor White
Write-Host "===========================================`n" -ForegroundColor Green

# 确认
Write-Host "是否使用以上配置继续部署？ (Y/N): " -ForegroundColor Cyan -NoNewline
$confirm = Read-Host

if ($confirm -notmatch '^[Yy]') {
    Write-Host "`n已取消部署。" -ForegroundColor Yellow
    exit 0
}

Write-Host "`n===========================================" -ForegroundColor Green
Write-Host "        开始部署" -ForegroundColor Green
Write-Host "===========================================`n" -ForegroundColor Green

# 步骤 1: 检查并卸载现有实例
Write-Host "[1/3] 检查现有实例..." -ForegroundColor Cyan
$existingInstances = wsl --list --quiet
if ($existingInstances -contains $InstanceName) {
    Write-Host "发现现有实例 '$InstanceName'，正在卸载..." -ForegroundColor Yellow
    wsl --terminate $InstanceName 2>$null
    wsl --unregister $InstanceName
    Write-Host "[OK] 已卸载现有实例" -ForegroundColor Green
}

# 步骤 2: 创建 WSL 实例
Write-Host "`n[2/3] 创建 WSL 2 实例..." -ForegroundColor Cyan

# 创建 WSL 路径
if (-not (Test-Path $WSLPath)) {
    New-Item -ItemType Directory -Path $WSLPath -Force | Out-Null
    Write-Host "[OK] 创建目录: $WSLPath" -ForegroundColor Green
}

# 创建实例目录
$instanceDir = "$WSLPath\$InstanceName"
if (-not (Test-Path $instanceDir)) {
    New-Item -ItemType Directory -Path $instanceDir -Force | Out-Null
    Write-Host "[OK] 创建目录: $instanceDir" -ForegroundColor Green
}

# 检查 install.tar.gz 是否存在
if (-not (Test-Path $InstallTarPath)) {
    Write-Host "`n[错误] install.tar.gz 未找到于 $InstallTarPath" -ForegroundColor Red
    Write-Host "请从以下地址下载 Ubuntu 24.04:" -ForegroundColor Yellow
    Write-Host "https://wslstorestorage.blob.core.windows.net/wslblob/Ubuntu2404-240425.AppxBundle" -ForegroundColor Cyan
    exit 1
}

# 导入实例
wsl --import $InstanceName $instanceDir $InstallTarPath --version 2
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] WSL 实例创建成功" -ForegroundColor Green
} else {
    Write-Host "[错误] WSL 实例创建失败" -ForegroundColor Red
    exit 1
}

# 步骤 3: 配置 WSL 实例
Write-Host "`n[3/3] 配置 WSL 实例..." -ForegroundColor Cyan

# 添加 ubuntu 用户到 sudo 组
wsl -d $InstanceName -u root usermod -aG sudo ubuntu
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] 将 ubuntu 用户添加到 sudo 组" -ForegroundColor Green
}

# 配置 wsl.conf 设置默认用户
wsl -d $InstanceName -u root -e bash -c "echo '[user]' >> /etc/wsl.conf"
wsl -d $InstanceName -u root -e bash -c "echo 'default=ubuntu' >> /etc/wsl.conf"
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] 配置默认用户为 ubuntu" -ForegroundColor Green
}

# 终止实例以使配置生效
Write-Host "`n终止 WSL 实例以使配置生效..." -ForegroundColor Cyan
wsl --terminate $InstanceName 2>$null
Write-Host "[OK] 实例已终止，配置已保存" -ForegroundColor Green

Write-Host "`n===========================================" -ForegroundColor Green
Write-Host "        部署完成！" -ForegroundColor Green
Write-Host "===========================================`n" -ForegroundColor Green
Write-Host "后续步骤：" -ForegroundColor Cyan
Write-Host "1. 在开始菜单找到 '$InstanceName' 并进入 WSL 实例" -ForegroundColor White
Write-Host "2. 克隆项目: git clone $ProjectUrl" -ForegroundColor White
Write-Host "3. 进入目录: cd wsl2-ubuntu-comfyui" -ForegroundColor White
Write-Host "4. 赋予执行权限: chmod +x main.sh scripts/*.sh" -ForegroundColor White
Write-Host "5. 执行安装: ./main.sh $InstallOption" -ForegroundColor White

Write-Host "`n按任意键关闭窗口..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
