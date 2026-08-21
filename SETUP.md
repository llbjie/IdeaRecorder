# IdeaRecorder 开发环境搭建指南

## 概述

本项目基于 Qt 6.7.3 + QML 开发，目标平台为 Android (arm64-v8a)。

## 路径配置

本项目路径通过环境变量配置，适配不同机器。首次搭建需设置以下变量：

| 变量名 | 说明 | 示例值 |
|--------|------|--------|
| `QT_ROOT` | Qt 安装根目录 | `D:\Qt` 或 `E:\Programs\QT` |
| `SDK_ROOT` | Android SDK 根目录 | `D:\SDK` 或 `E:\SDK` |

设置命令（PowerShell）：

```powershell
# 根据你的实际路径修改
[System.Environment]::SetEnvironmentVariable("QT_ROOT", "D:\Qt", "User")
[System.Environment]::SetEnvironmentVariable("SDK_ROOT", "D:\SDK", "User")
```

设置后重启终端生效。以下文档用 `%QT_ROOT%` 和 `%SDK_ROOT%` 表示。

## 所需工具

| 工具 | 版本要求 | 安装方式 |
|------|---------|---------|
| CMake | >= 3.16 | `scoop install cmake` |
| Ninja | >= 1.10 | `scoop install ninja` |
| JDK | 17 | `scoop install openjdk17` |
| Qt 6 (Desktop) | 6.7.3 | aqtinstall |
| Qt 6 (Android) | 6.7.3 | aqtinstall |
| Android SDK | - | cmdline-tools |
| Android NDK | r27c | sdkmanager |

## 安装步骤

### 1. 安装基础构建工具

```bash
scoop install cmake ninja openjdk17
```

### 2. 安装 aqtinstall

```bash
pip install aqtinstall
```

### 3. 安装 Qt 6.7.3

安装桌面版（构建工具依赖）和 Android 版（目标平台）：

```bash
# 桌面版 (MSVC)
aqt install-qt windows desktop 6.7.3 win64_msvc2019_64 --outputdir "%QT_ROOT%"

# Android 版 (arm64-v8a)
aqt install-qt windows android 6.7.3 android_arm64_v8a --outputdir "%QT_ROOT%"
```

安装后目录结构：
```
%QT_ROOT%\6.7.3\
├── msvc2019_64\          # 桌面版 Qt (host tools)
└── android_arm64_v8a\    # Android 版 Qt
```

### 4. 安装 Android SDK

下载 Android SDK 命令行工具（Google 官网可能被墙，可使用腾讯镜像）：

```bash
# 腾讯镜像
Invoke-WebRequest -Uri "https://mirrors.cloud.tencent.com/AndroidSDK/commandlinetools-win-11076708_latest.zip" -OutFile "cmdline-tools.zip"
```

解压到 `%SDK_ROOT%\android-sdk\cmdline-tools\latest\`

### 5. 安装 SDK 组件

```powershell
$env:JAVA_HOME = (Get-Command java).Source | Split-Path | Split-Path
$env:ANDROID_SDK_ROOT = "$env:SDK_ROOT\android-sdk"

# 安装 platform-tools, build-tools, platforms, NDK
echo "y" | & "$env:SDK_ROOT\android-sdk\cmdline-tools\latest\bin\sdkmanager.bat" `
  --sdk_root="$env:SDK_ROOT\android-sdk" `
  "platform-tools" `
  "platforms;android-34" `
  "build-tools;34.0.0" `
  "ndk;27.2.12479018" `
  --no_https
```

### 6. 设置环境变量

```powershell
[System.Environment]::SetEnvironmentVariable("JAVA_HOME", (Get-Command java).Source | Split-Path | Split-Path, "User")
[System.Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", "$env:SDK_ROOT\android-sdk", "User")
[System.Environment]::SetEnvironmentVariable("ANDROID_HOME", "$env:SDK_ROOT\android-sdk", "User")
[System.Environment]::SetEnvironmentVariable("ANDROID_NDK_ROOT", "$env:SDK_ROOT\android-sdk\ndk\27.2.12479018", "User")
```

## 构建项目

```powershell
# 配置
& "%QT_ROOT%\6.7.3\android_arm64_v8a\bin\qt-cmake.bat" -G Ninja `
  -B build-android -S . `
  -DQT_HOST_PATH="%QT_ROOT%/6.7.3/msvc2019_64"

# 编译
cmake --build build-android

# APK 输出路径
# build-android\android-build\build\outputs\apk\debug\android-build-debug.apk
```

## 常见问题

### 1. `dl.google.com` 被墙

使用腾讯镜像下载 SDK cmdline-tools，Gradle 配置见 `build-android/android-build/build.gradle`（已配置阿里云镜像）。

### 2. `services.gradle.org` 被墙

创建 `~/.gradle/init.gradle`：

```groovy
allprojects {
    repositories {
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/central' }
        maven { url 'https://maven.aliyun.com/repository/public' }
    }
}
```

### 3. 编译报错 `Qt6_DIR`

确保使用 `qt-cmake.bat` 而不是直接 `cmake`，它会自动设置 Qt 路径。

### 4. APK 打包超时

Gradle 首次运行需下载依赖，确保网络通畅或已配置镜像。

### 5. VSCode 配置

VSCode 需要安装 CMake Tools 插件。项目已包含 `.vscode/` 配置：

- `settings.json` — 编码设置（Qt 路径不再硬编码）
- `tasks.json` — 构建任务（Configure Android / Build Android）

VSCode 使用前需确保：
1. 已设置 `QT_ROOT` 和 `SDK_ROOT` 环境变量
2. 重启 VSCode 使其读取新的环境变量
3. 首次使用需运行 "Configure Android" 任务配置 CMake

## 不同机器配置示例

**机器 A（E 盘）：**
```powershell
[System.Environment]::SetEnvironmentVariable("QT_ROOT", "E:\Programs\QT", "User")
[System.Environment]::SetEnvironmentVariable("SDK_ROOT", "E:\SDK", "User")
```

**机器 B（D 盘）：**
```powershell
[System.Environment]::SetEnvironmentVariable("QT_ROOT", "D:\Qt", "User")
[System.Environment]::SetEnvironmentVariable("SDK_ROOT", "D:\AndroidSDK", "User")
```

**机器 C（C 盘）：**
```powershell
[System.Environment]::SetEnvironmentVariable("QT_ROOT", "C:\Qt", "User")
[System.Environment]::SetEnvironmentVariable("SDK_ROOT", "C:\SDK", "User")
```
