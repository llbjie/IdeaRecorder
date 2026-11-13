cmake_minimum_required(VERSION 3.16)
project(IdeaRecorder VERSION 2.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

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