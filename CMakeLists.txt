cmake_minimum_required(VERSION 3.16)
project(IdeaRecorder VERSION 2.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# 仅在 Windows 上自动设置 Qt 路径；Linux 下依赖系统的标准路径自动查找
if(WIN32 AND NOT DEFINED CMAKE_PREFIX_PATH)
    set(CMAKE_PREFIX_PATH "D:/Programs/QT/6.8.0/msvc2022_64" CACHE PATH "Qt installation prefix")
endif()

find_package(Qt6 REQUIRED COMPONENTS Core Quick Sql Qml)

qt_standard_project_setup(REQUIRES 6.5)

# 先创建可执行文件目标
qt_add_executable(IdeaRecorder
    src/main.cpp
    src/DatabaseManager.cpp
    src/IdeaModel.cpp
    src/TagModel.cpp
)

# 再把这个可执行文件作为 QML 模块的 backing target
qt_add_qml_module(IdeaRecorder
    URI IdeaRecorderModule   
    VERSION 1.0
    QML_FILES
        qml/main.qml
        qml/pages/RecordPage.qml
        qml/pages/ListPage.qml
        qml/pages/StatisticsPage.qml
        qml/components/BubbleWordCloud.qml
        qml/components/BottomNavButton.qml
)

target_link_libraries(IdeaRecorder PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Sql
)