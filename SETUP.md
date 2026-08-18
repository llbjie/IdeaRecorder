# IdeaRecorder 开发环境搭建指南

## 概述

本项目基于 Qt 6.7.3 + QML 开发，目标平台为 Android (arm64-v8a)。

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

注意：如果不存在E盘，则安装到D盘对应的位置，反过来也是一样

如果没有 Programs 目录，则安装在"Program Files" 目录

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
aqt install-qt windows desktop 6.7.3 win64_msvc2019_64 --outputdir "E:\Programs\QT"

# Android 版 (arm64-v8a)
aqt install-qt windows android 6.7.3 android_arm64_v8a --outputdir "E:\Programs\QT"
```

安装路径约定：
- 桌面版：`E:\Programs\QT\6.7.3\msvc2019_64`
- Android 版：`E:\Programs\QT\6.7.3\android_arm64_v8a`

### 4. 安装 Android SDK

下载 Android SDK 命令行工具（Google 官网可能被墙，可使用腾讯镜像）：

```bash
# 腾讯镜像
Invoke-WebRequest -Uri "https://mirrors.cloud.tencent.com/AndroidSDK/commandlinetools-win-11076708_latest.zip" -OutFile "cmdline-tools.zip"
```

解压到 `E:\SDK\android-sdk\cmdline-tools\latest\`

### 5. 安装 SDK 组件

```bash
$env:JAVA_HOME = "E:\Programs\Scoop\apps\openjdk17\current"
$env:ANDROID_SDK_ROOT = "E:\SDK\android-sdk"

# 安装 platform-tools, build-tools, platforms, NDK
echo "y" | & "E:\SDK\android-sdk\cmdline-tools\latest\bin\sdkmanager.bat" `
  --sdk_root="E:\SDK\android-sdk" `
  "platform-tools" `
  "platforms;android-34" `
  "build-tools;34.0.0" `
  "ndk;27.2.12479018" `
  --no_https
```

### 6. 设置环境变量

以下环境变量需设为**用户级**：

| 变量名 | 值 |
|--------|---|
| `JAVA_HOME` | `E:\Programs\Scoop\apps\openjdk17\current` |
| `ANDROID_SDK_ROOT` | `E:\SDK\android-sdk` |
| `ANDROID_HOME` | `E:\SDK\android-sdk` |
| `ANDROID_NDK_ROOT` | `E:\SDK\android-sdk\ndk\27.2.12479018` |

PowerShell 设置命令：

```powershell
[System.Environment]::SetEnvironmentVariable("JAVA_HOME", "E:\Programs\Scoop\apps\openjdk17\current", "User")
[System.Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", "E:\SDK\android-sdk", "User")
[System.Environment]::SetEnvironmentVariable("ANDROID_HOME", "E:\SDK\android-sdk", "User")
[System.Environment]::SetEnvironmentVariable("ANDROID_NDK_ROOT", "E:\SDK\android-sdk\ndk\27.2.12479018", "User")
```

## 构建项目

```bash
# 配置 (在项目根目录执行)
E:\Programs\QT\6.7.3\android_arm64_v8a\bin\qt-cmake.bat -G Ninja `
  -B build-android -S . `
  -DQT_HOST_PATH="E:/Programs/QT/6.7.3/msvc2019_64"

# 编译
cmake --build build-android
```

## 目录结构

```
E:\Programs\QT\6.7.3\
├── msvc2019_64\          # 桌面版 Qt (host tools)
└── android_arm64_v8a\    # Android 版 Qt

E:\SDK\android-sdk\
├── cmdline-tools\        # SDK 命令行工具
├── platform-tools\       # adb 等
├── build-tools\          # aapt2, d8 等
├── platforms\            # android.jar
└── ndk\                  # NDK (r27c)
```
