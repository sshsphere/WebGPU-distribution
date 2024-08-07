cmake_minimum_required(VERSION 3.20)
project(WebGPUProject LANGUAGES C CXX)

include(FetchContent)

# FetchContent configuration for Dawn
FetchContent_Declare(
  dawn
  GIT_REPOSITORY https://dawn.googlesource.com/dawn
  GIT_TAG origin/main
)

FetchContent_MakeAvailable(dawn)

add_library(webgpu INTERFACE)
target_include_directories(webgpu INTERFACE "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
                                            "$<INSTALL_INTERFACE:include>")

# Installation for webgpu target
install(TARGETS webgpu
    EXPORT webgpuTargets
    INCLUDES DESTINATION include
)

install(EXPORT webgpuTargets
    FILE webgpuTargets.cmake
    NAMESPACE webgpu::
    DESTINATION lib/cmake/webgpu
)
