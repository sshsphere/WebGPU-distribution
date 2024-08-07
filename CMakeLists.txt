cmake_minimum_required(VERSION 3.0.0...3.24 FATAL_ERROR)
project(webgpu-backend-dawn VERSION 1.0.0)

message(STATUS "Using Dawn backend for WebGPU")

# Create an interface library for WebGPU
add_library(webgpu INTERFACE)

# Handle the case where we're building with Emscripten
if (EMSCRIPTEN)
    target_include_directories(webgpu INTERFACE
        "${CMAKE_CURRENT_SOURCE_DIR}/include-emscripten"
    )
    target_compile_definitions(webgpu INTERFACE WEBGPU_BACKEND_EMSCRIPTEN)
    target_link_options(webgpu INTERFACE
        -sUSE_WEBGPU
    )
else()
    include(cmake/FetchDawn.cmake)

    target_link_libraries(webgpu INTERFACE webgpu_dawn)

    target_include_directories(webgpu INTERFACE
        "${CMAKE_CURRENT_SOURCE_DIR}/include"
        "${CMAKE_BINARY_DIR}/_deps/dawn-src/include"
    )

    target_compile_definitions(webgpu INTERFACE WEBGPU_BACKEND_DAWN)
endif()

function(target_copy_webgpu_binaries Target)
endfunction()

install(TARGETS webgpu
    EXPORT webgpu-export
    DESTINATION lib
)

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/
    DESTINATION include
)

if (EMSCRIPTEN)
    install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include-emscripten/
        DESTINATION include
    )
else()
    install(DIRECTORY ${CMAKE_BINARY_DIR}/_deps/dawn-src/include/
        DESTINATION include
    )
endif()

install(EXPORT webgpu-export
    FILE webgpu-config.cmake
    DESTINATION lib/cmake/webgpu
)
