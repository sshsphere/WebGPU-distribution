include(FetchContent)

# Declare Dawn as a FetchContent target
FetchContent_Declare(
  dawn
  GIT_REPOSITORY https://dawn.googlesource.com/dawn
  GIT_TAG origin/main
)

FetchContent_MakeAvailable(dawn)

# List of all Dawn targets that are valid for installation
set(AllDawnTargets
    absl
    dawn_headers
    dawn_platform_headers
    dawn_proc
    dawn_utils
    dawn_wire
    dawncpp_headers
    dawncpp
    dawn_native
    dawn_native_headers
    dawn_swiftshader
    dawn_vulkan
    dawn_webgpu_headers
    tint
    tint_core
    tint_glsl
    tint_hlsl
    tint_msl
    tint_parser
    tint_reader
    tint_writer
    tint_lang_glsl_reader
    tint_lang_glsl_writer
    tint_lang_hlsl_reader
    tint_lang_hlsl_writer
    tint_lang_msl_writer
    tint_lang_spirv_reader
    tint_lang_spirv_writer
    tint_lang_wgsl_reader
    tint_lang_wgsl_writer
    tint_utils
)

foreach (Target ${AllDawnTargets})
    if (TARGET ${Target})
        get_property(AliasedTarget TARGET "${Target}" PROPERTY ALIASED_TARGET)
        if("${AliasedTarget}" STREQUAL "")
            set_property(TARGET ${Target} PROPERTY FOLDER "Dawn")
            install(TARGETS ${Target}
                EXPORT dawnTargets
                LIBRARY DESTINATION lib
                ARCHIVE DESTINATION lib
                RUNTIME DESTINATION bin
                INCLUDES DESTINATION include
            )
        endif()
    endif()
endforeach()

install(EXPORT dawnTargets
    FILE dawnTargets.cmake
    NAMESPACE dawn::
    DESTINATION lib/cmake/dawn
)

# Ensure the include directories are set correctly
target_include_directories(dawn_utils PUBLIC "${CMAKE_BINARY_DIR}/_deps/dawn-src/src")
