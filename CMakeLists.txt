cmake_minimum_required(VERSION 3.0.0...3.24 FATAL_ERROR)
project(webgpu-backend-dawn VERSION 1.0.0)

message(STATUS "Using Dawn backend for WebGPU")

# Create an interface library for WebGPU
add_library(webgpu INTERFACE)

# Handle the case where we're building with Emscripten
if (EMSCRIPTEN)

    # Include the Emscripten-specific headers
    target_include_directories(webgpu INTERFACE
        "${CMAKE_CURRENT_SOURCE_DIR}/include-emscripten"
    )

    # Define a preprocessor symbol to indicate the WebGPU backend is Emscripten
    target_compile_definitions(webgpu INTERFACE WEBGPU_BACKEND_EMSCRIPTEN)

    # Link options for Emscripten to handle WebGPU symbols
    target_link_options(webgpu INTERFACE
        -sUSE_WEBGPU
    )

else()

    # Include the FetchDawn script to download and configure Dawn
    include(cmake/FetchDawn.cmake)

    # Link the Dawn library
    target_link_libraries(webgpu INTERFACE webgpu_dawn)

    # Include the Dawn headers and project-specific headers
    target_include_directories(webgpu INTERFACE
        "${CMAKE_CURRENT_SOURCE_DIR}/include"
        "${CMAKE_BINARY_DIR}/_deps/dawn-src/include"
    )

    # Define a preprocessor symbol to indicate the WebGPU backend is Dawn
    target_compile_definitions(webgpu INTERFACE WEBGPU_BACKEND_DAWN)

endif()

# Stub function for copying WebGPU binaries, does nothing in this static build
function(target_copy_webgpu_binaries Target)
    # No operation needed for static linkage
endfunction()

# Install rules
# Install the interface library
install(TARGETS webgpu
    EXPORT webgpu-export
    DESTINATION lib
)

# Install the header files
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

# Export the webgpu target for use with find_package
install(EXPORT webgpu-export
    FILE webgpu-config.cmake
    DESTINATION lib/cmake/webgpu
)
