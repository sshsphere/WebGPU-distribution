# Prevent multiple includes
if (TARGET dawn_native)
    return()
endif()

include(FetchContent)

FetchContent_Declare(
    dawn
    DOWNLOAD_COMMAND
        cd ${FETCHCONTENT_BASE_DIR}/dawn-src &&
        git init &&
        git fetch --depth=1 https://dawn.googlesource.com/dawn chromium/6536 &&
        git reset --hard FETCH_HEAD

    PATCH_COMMAND
        "${CMAKE_COMMAND}" -E copy
        "${CMAKE_CURRENT_LIST_DIR}/../patch/tools/fetch_dawn_dependencies.py"
        tools
)

FetchContent_GetProperties(dawn)
if (NOT dawn_POPULATED)
    FetchContent_Populate(dawn)

    # This option replaces depot_tools
    set(DAWN_FETCH_DEPENDENCIES ON)

    # A more minimalistic choice of backend than Dawn's default
    if (APPLE)
        set(USE_VULKAN OFF)
        set(USE_METAL ON)
    else()
        set(USE_VULKAN ON)
        set(USE_METAL OFF)
    endif()
    set(DAWN_ENABLE_D3D11 OFF CACHE BOOL "Enable compilation of the D3D11 backend")
    set(DAWN_ENABLE_D3D12 OFF CACHE BOOL "Enable compilation of the D3D12 backend")
    set(DAWN_ENABLE_METAL ${USE_METAL} CACHE BOOL "Enable compilation of the Metal backend")
    set(DAWN_ENABLE_NULL OFF CACHE BOOL "Enable compilation of the Null backend")
    set(DAWN_ENABLE_DESKTOP_GL OFF CACHE BOOL "Enable compilation of the OpenGL backend")
    set(DAWN_ENABLE_OPENGLES OFF CACHE BOOL "Enable compilation of the OpenGL ES backend")
    set(DAWN_ENABLE_VULKAN ${USE_VULKAN} CACHE BOOL "Enable compilation of the Vulkan backend")
    set(TINT_BUILD_SPV_READER OFF CACHE BOOL "Build the SPIR-V input reader")
    if(${DAWN_ENABLE_D3D11} OR ${DAWN_ENABLE_D3D12})
        set(TINT_BUILD_HLSL_WRITER ON CACHE BOOL "Build the HLSL output writer" FORCE)
    endif()
    if(${DAWN_ENABLE_DESKTOP_GL} OR ${DAWN_ENABLE_OPENGLES})
        set(TINT_BUILD_GLSL_WRITER ON CACHE BOOL "Build the GLSL output writer" FORCE)
    endif()
    if(${DAWN_ENABLE_VULKAN})
        set(TINT_BUILD_SPV_WRITER ON CACHE BOOL "Build the SPIR-V output writer" FORCE)
    endif()
    if(${DAWN_ENABLE_METAL})
        set(TINT_BUILD_MSL_WRITER ON CACHE BOOL "Build the MSL output writer" FORCE)
    endif()

    # Disable unneeded parts
    set(DAWN_BUILD_SAMPLES OFF CACHE BOOL "Enables building Dawn's samples")
    set(TINT_BUILD_TINTD OFF CACHE BOOL "Build the WGSL language server")
    set(TINT_BUILD_TESTS OFF CACHE BOOL "Build tests")
    set(TINT_BUILD_FUZZERS OFF CACHE BOOL "Build fuzzers")
    set(TINT_BUILD_AST_FUZZER OFF CACHE BOOL "Build AST fuzzer")
    set(TINT_BUILD_REGEX_FUZZER OFF CACHE BOOL "Build regex fuzzer")
    set(TINT_BUILD_IR_FUZZER OFF CACHE BOOL "Build IR fuzzer")
    set(TINT_BUILD_BENCHMARKS OFF CACHE BOOL "Build Tint benchmarks")
    set(TINT_BUILD_AS_OTHER_OS OFF CACHE BOOL "Override OS detection to force building of *_other.cc files")

    add_subdirectory(${dawn_SOURCE_DIR} ${dawn_BINARY_DIR} EXCLUDE_FROM_ALL)

    # Ensure all necessary targets are added to the export set
    set(AllDawnTargets
        dawn_common
        dawn_glfw
        dawn_headers
        dawn_native
        dawn_platform
        dawn_proc
        dawn_utils
        dawn_wire
        dawncpp
        dawncpp_headers
        webgpu_dawn
        partition_alloc
        dawn_internal_config
        tint_api
        SPIRV-Tools-opt
        tint_lang_core_ir  # Added missing target
        tint_lang_core_type  # Added missing target
    )

    foreach (Target ${AllDawnTargets})
        if (TARGET ${Target})
            # Is a target...
            get_property(AliasedTarget TARGET "${Target}" PROPERTY ALIASED_TARGET)
            if("${AliasedTarget}" STREQUAL "")
                # ...and is not an alias -> move to the Dawn folder
                set_property(TARGET ${Target} PROPERTY FOLDER "Dawn")
                # Add to export set
                install(TARGETS ${Target} EXPORT webgpu-export)
            endif()
        endif()
    endforeach()

    # Add include directories to the export set
    install(DIRECTORY "${dawn_SOURCE_DIR}/include/" DESTINATION include)

    # This is likely needed for other targets as well
    # TODO: Notify this upstream (is this still needed?)
    target_include_directories(dawn_utils PUBLIC "${CMAKE_BINARY_DIR}/_deps/dawn-src/src")
endif()
