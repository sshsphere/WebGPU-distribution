cmake_minimum_required(VERSION 3.0.0...3.24 FATAL_ERROR)
project(webgpu-backend-dawn VERSION 1.0.0)

message(STATUS "Using Dawn backend for WebGPU")

add_library(webgpu INTERFACE)

if (EMSCRIPTEN)

    target_include_directories(webgpu INTERFACE
        "$<INSTALL_INTERFACE:include>"
        "${CMAKE_CURRENT_SOURCE_DIR}/include-emscripten"
    )

    target_compile_definitions(webgpu INTERFACE WEBGPU_BACKEND_EMSCRIPTEN)

    target_link_options(webgpu INTERFACE
        -sUSE_WEBGPU # Handle WebGPU symbols
    )

else (EMSCRIPTEN)

    include(cmake/FetchDawn.cmake)

    target_link_libraries(webgpu INTERFACE webgpu_dawn)

    target_include_directories(webgpu INTERFACE
        "$<INSTALL_INTERFACE:include>"
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
        "$<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/_deps/dawn-src/include>"
    )

    target_compile_definitions(webgpu INTERFACE WEBGPU_BACKEND_DAWN)

endif (EMSCRIPTEN)

# Install the webgpu library
install(TARGETS webgpu EXPORT webgpu-targets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
)

# Install the export set
install(EXPORT webgpu-targets
    FILE webgpu-targets.cmake
    NAMESPACE webgpu::
    DESTINATION lib/cmake/webgpu
)

if (NOT EMSCRIPTEN)
    # Export dawn-targets
    install(EXPORT dawn-targets
        FILE dawn-targets.cmake
        NAMESPACE dawn::
        DESTINATION lib/cmake/dawn
    )
endif()

# Install include directories
if (EMSCRIPTEN)
    install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/include-emscripten"
            DESTINATION include)
else()
    install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/include"
            DESTINATION include)
    install(DIRECTORY "${CMAKE_BINARY_DIR}/_deps/dawn-src/include"
            DESTINATION include/dawn)
endif()
