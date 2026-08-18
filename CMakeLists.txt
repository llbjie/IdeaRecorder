cmake_minimum_required(VERSION 3.16)
project(IdeaRecorder VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
set(QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")

find_package(Qt6 REQUIRED COMPONENTS
    Core Quick Sql
)

qt_standard_project_setup()

qt_add_executable(IdeaRecorder
    src/main.cpp
)

qt_add_qml_module(IdeaRecorder
    URI IdeaRecorder
    VERSION 1.0
    QML_FILES
        qml/main.qml
        qml/pages/RecordPage.qml
        qml/pages/ListPage.qml
        qml/pages/StatisticsPage.qml
)

target_link_libraries(IdeaRecorder PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Sql
)

set(ANDROID_ABI "arm64-v8a")
set(ANDROID_MIN_SDK_VERSION 26)
set(ANDROID_TARGET_SDK_VERSION 33)