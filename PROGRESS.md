# IdeaRecorder 项目进度

## 当前状态

**编译状态：** CMake 配置成功，C++ 编译成功，APK 打包成功
**代码已推送至：** https://github.com/llbjie/IdeaRecorder (master 分支)
**最新进度：** [2026-08-20](docs/progress/2026-08-20.md)

---

## 功能完成情况

### 已完成

| 模块 | 文件 | 状态 | 说明 |
|------|------|------|------|
| **应用入口** | `src/main.cpp` | 已完成 | 初始化 SQLite 数据库，加载 QML 引擎，注入 `dbManager` 上下文属性 |
| **数据库管理** | `src/DatabaseManager.h/cpp` | 已完成 | SQLite CRUD + 标签管理 + 数据库版本追踪（v1→v2迁移） |
| **数据模型** | `src/IdeaModel.h/cpp` | 已完成 | `Idea` 类：id/content/tags/createdAt |
| **标签模型** | `src/TagModel.h/cpp` | 已完成 | `Tag` 类：id/name，供标签管理使用 |
| **记录页面** | `qml/pages/RecordPage.qml` | 已完成 | 文本输入 + 标签选择（绿色芯片）+ 添加/删除标签 + 保存 |
| **列表页面** | `qml/pages/ListPage.qml` | 已完成 | 分页展示 + 点击编辑（RecordPage风格）+ 删除确认弹窗 |
| **统计页面** | `qml/pages/StatisticsPage.qml` | 已完成 | 统计卡片 + 关键词云 + 标签词云 |
| **主界面** | `qml/main.qml` | 已完成 | SwipeView + 自定义底部导航栏 |
| **词云组件** | `qml/components/BubbleWordCloud.qml` | 已完成 | 气泡词云 + 点击Toast频率提示 |
| **词云组件** | `qml/components/WordCloud.qml` | 已完成 | 词云基础组件 |
| **导航按钮** | `qml/components/BottomNavButton.qml` | 已完成 | 底部导航按钮组件 |
| **构建系统** | `CMakeLists.txt` | 已完成 | CMake配置，Qt 6.7.3 + Android arm64-v8a 交叉编译 |
| **Android配置** | `android/AndroidManifest.xml` | 已完成 | 包名 `com.idearecorder.app` |
| **列表页面** | `qml/pages/ListPage.qml` | 已完成 | ListView 展示所有想法，显示内容/标签/时间，支持删除，空状态提示，`refreshList()` 方法 |
| **统计页面** | `qml/pages/StatisticsPage.qml` | 已完成 | 总想法数卡片 + 标签数卡片 + 标签列表 + 气泡词云区域，调用 `dbManager` 获取数据 |
| **主界面** | `qml/main.qml` | 已完成 | SwipeView + 自定义底部导航栏（列表/记录/统计），带滑动指示线动画 |
| **词云组件** | `qml/components/BubbleWordCloud.qml` | 已完成 | 统计页使用的气泡词云可视化组件，支持点击显示频率 Toast |
| **词云组件** | `qml/components/WordCloud.qml` | 已完成 | 词云基础组件 |
| **导航按钮** | `qml/components/BottomNavButton.qml` | 已完成 | 底部导航按钮组件 |
| **QML 资源** | `qml/resources.qrc` | 已完成 | QML 资源文件，管理 QML 文件的 Qt 资源注册 |
| **构建系统** | `CMakeLists.txt` | 已完成 | CMake 配置，Qt 6.7.3 + Android arm64-v8a 交叉编译 |
| **Android 配置** | `android/AndroidManifest.xml` | 已完成 | 包名 `com.idearecorder.app`，Activity/权限配置 |
| **Android 样式** | `android/res/values/styles.xml` | 已完成 | AppTheme 定义 |
| **开发文档** | `SETUP.md` | 已完成 | 环境搭建指南：工具安装、SDK 配置、构建命令 |
| **项目说明** | `README.md` | 已完成 | 项目简介 |
| **环境搭建** | Qt 6.7.3 + Android SDK + NDK | 已完成 | 全部安装到 `E:\Programs\QT` 和 `E:\SDK` |

### 未完成 / 待实现

| 模块 | 文件 | 状态 | 说明 |
|------|------|------|------|
| **统计服务** | `src/StatisticsService.h/cpp` | 空文件 | 未实现，统计逻辑目前内联在 QML 层 (StatisticsPage.qml) |
| **APK 打包** | - | 未完成 | 编译到 29/30 步成功，最后 APK 打包因超时中断，需重新执行 `cmake --build build-android --target apk` |

---

## 技术架构

```
┌─────────────────────────────────────┐
│           QML UI Layer              │
│  main.qml (SwipeView + TabBar)     │
│  ├── RecordPage.qml  (记录)         │
│  ├── ListPage.qml    (列表)         │
│  └── StatisticsPage.qml (统计)      │
│      └── BubbleWordCloud (词云)      │
└──────────┬──────────────────────────┘
           │ Q_INVOKABLE / Context Property
           ▼
┌─────────────────────────────────────┐
│         C++ Backend Layer           │
│  main.cpp (应用入口)                │
│  DatabaseManager (SQLite CRUD)      │
│  IdeaModel (数据模型)               │
└──────────┬──────────────────────────┘
           │ Qt SQL Module
           ▼
┌─────────────────────────────────────┐
│         SQLite Database             │
│  ideas 表: id, content, tags,       │
│            created_at               │
└─────────────────────────────────────┘
```

## 数据库结构

```sql
CREATE TABLE ideas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    content TEXT NOT NULL,
    tags TEXT DEFAULT '',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

---

## 构建命令

```bash
# 设置环境变量（当前会话）
$env:JAVA_HOME = "E:\Programs\Scoop\apps\openjdk17\current"
$env:ANDROID_SDK_ROOT = "E:\SDK\android-sdk"
$env:ANDROID_NDK_ROOT = "E:\SDK\android-sdk\ndk\27.2.12479018"

# 配置
E:\Programs\QT\6.7.3\android_arm64_v8a\bin\qt-cmake.bat -G Ninja `
  -B build-android -S . `
  -DQT_HOST_PATH="E:/Programs/QT/6.7.3/msvc2019_64"

# 编译
cmake --build build-android

# 打包 APK
cmake --build build-android --target apk
```

---

## 已知问题

1. **StatisticsService 未实现** — 统计逻辑在 QML 中完成，未抽取到 C++ 层
2. **CMakeLists.txt 中 Qt6_DIR 硬编码** — 已删除，现在由 qt-cmake.bat 自动设置
3. **APK 打包未验证** — Gradle 镜像已配置，待重新执行打包
4. **Android 字体显示异常** — 使用 font.pointSize 后中文字体笔画仍然挤在一起，待排查
5. **CMakeLists.txt 引用了 StatisticsService 但文件为空** — 当前 CMakeLists 未引用 StatisticsService，无影响
