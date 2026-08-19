cmake_minimum_required(VERSION 3.16)
project(IdeaRecorder VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
set(QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
set(Qt6_DIR "E:/Programs/QT/6.7.3/msvc2019_64/lib/cmake/Qt6" CACHE PATH "Path to Qt6 CMake config")

find_package(Qt6 REQUIRED COMPONENTS
    Core Quick Sql
)

qt_standard_project_setup()

qt6_add_resources(QML_RESOURCES
    "qml/resources.qrc"
)

qt_add_executable(IdeaRecorder
    src/main.cpp
    src/DatabaseManager.cpp
    src/IdeaModel.cpp
    ${QML_RESOURCES}
)

target_link_libraries(IdeaRecorder PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Sql
)

set(ANDROID_ABI "arm64-v8a")
set(ANDROID_MIN_SDK_VERSION 26)
set(ANDROID_TARGET_SDK_VERSION 33)