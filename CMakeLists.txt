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

    # Ensure that FetchDawn provides correct paths
    if (NOT TARGET webgpu_dawn)
        message(FATAL_ERROR "Failed to find or build the Dawn library. Please check FetchDawn.cmake.")
    endif()

    # Link the Dawn library
    target_link_libraries(webgpu INTERFACE webgpu_dawn)

    # Ensure paths do not contain user-specific directories
    set(DawnIncludeDir "${CMAKE_BINARY_DIR}/_deps/dawn-src/include")
    if (EXISTS "${DawnIncludeDir}")
        target_include_directories(webgpu INTERFACE
            "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
            "$<BUILD_INTERFACE:${DawnIncludeDir}>"
        )
    else()
        message(FATAL_ERROR "Dawn include directory does not exist: ${DawnIncludeDir}")
    endif()

    # Define a preprocessor symbol to indicate the WebGPU backend is Dawn
    target_compile_definitions(webgpu INTERFACE WEBGPU_BACKEND_DAWN)

endif()

# Stub function for copying WebGPU binaries, does nothing in this static build
function(target_copy_webgpu_binaries Target)
    # No operation needed for static linkage
endfunction()

# Collect all Dawn targets to be installed
set(DawnTargets
    dawn_native
    dawn_headers
    webgpu_dawn
)

# Install rules
# Install the interface library
install(TARGETS webgpu
    EXPORT webgpu-export
    DESTINATION lib
)

# Install Dawn library and its dependencies if it's being used
if (NOT EMSCRIPTEN)
    install(TARGETS ${DawnTargets}
        EXPORT webgpu-export
        DESTINATION lib
    )
endif()

# Install the header files
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/
    DESTINATION include
)

if (EMSCRIPTEN)
    install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include-emscripten/
        DESTINATION include
    )
else()
    install(DIRECTORY ${DawnIncludeDir}/
        DESTINATION include
    )
endif()

# Export the webgpu target for use with find_package
install(EXPORT webgpu-export
    FILE webgpu-config.cmake
    DESTINATION lib/cmake/webgpu
)
