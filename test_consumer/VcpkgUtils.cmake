# VcpkgUtils.cmake
# Utility functions for working with vcpkg dependencies
# 
# This module provides functions to handle common vcpkg-related tasks,
# particularly DLL copying on Windows platforms.

include_guard(GLOBAL)

# Function to copy vcpkg DLLs to the target's output directory
# 
# This function automatically copies all required vcpkg DLLs to the executable's
# output directory on Windows. This is essential for executables to run without
# manually copying DLLs.
#
# Usage:
#   copy_vcpkg_dlls(target_name)
#
# Parameters:
#   target_name - The name of the executable target that needs DLL copying
#
# Example:
#   add_executable(my_app main.cpp)
#   target_link_libraries(my_app PRIVATE some_vcpkg_lib)
#   copy_vcpkg_dlls(my_app)
#
function(copy_vcpkg_dlls target_name)
    # Only process on Windows with vcpkg toolchain
    if(NOT WIN32 OR NOT DEFINED CMAKE_TOOLCHAIN_FILE)
        return()
    endif()

    # Validate that the target exists
    if(NOT TARGET ${target_name})
        message(WARNING "copy_vcpkg_dlls: Target '${target_name}' does not exist")
        return()
    endif()

    # Get target type to ensure it's an executable
    get_target_property(target_type ${target_name} TYPE)
    if(NOT target_type STREQUAL "EXECUTABLE")
        message(WARNING "copy_vcpkg_dlls: Target '${target_name}' is not an executable (type: ${target_type})")
        return()
    endif()

    # Find vcpkg root directory by traversing up from toolchain file
    get_filename_component(VCPKG_ROOT_DIR ${CMAKE_TOOLCHAIN_FILE} DIRECTORY)
    get_filename_component(VCPKG_ROOT_DIR ${VCPKG_ROOT_DIR} DIRECTORY)
    get_filename_component(VCPKG_ROOT_DIR ${VCPKG_ROOT_DIR} DIRECTORY)
    
    # Locate the applocal.ps1 script
    set(VCPKG_APPLOCAL_SCRIPT "${VCPKG_ROOT_DIR}/scripts/buildsystems/msbuild/applocal.ps1")
    
    if(NOT EXISTS ${VCPKG_APPLOCAL_SCRIPT})
        message(WARNING "copy_vcpkg_dlls: vcpkg applocal.ps1 script not found at: ${VCPKG_APPLOCAL_SCRIPT}")
        return()
    endif()

    # Determine the vcpkg triplet
    if(NOT DEFINED VCPKG_TARGET_TRIPLET)
        # Try to detect the triplet based on platform and architecture
        if(CMAKE_SIZEOF_VOID_P EQUAL 8)
            set(VCPKG_TARGET_TRIPLET "x64-windows")
        else()
            set(VCPKG_TARGET_TRIPLET "x86-windows")
        endif()
        message(STATUS "copy_vcpkg_dlls: Auto-detected VCPKG_TARGET_TRIPLET as ${VCPKG_TARGET_TRIPLET}")
    endif()

    # Verify the vcpkg installed directory exists
    # Try local vcpkg_installed first, then global
    set(VCPKG_INSTALLED_DIR "${CMAKE_BINARY_DIR}/vcpkg_installed/${VCPKG_TARGET_TRIPLET}")
    if(NOT EXISTS ${VCPKG_INSTALLED_DIR})
        set(VCPKG_INSTALLED_DIR "${VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}")
    endif()
    
    if(NOT EXISTS ${VCPKG_INSTALLED_DIR})
        message(WARNING "copy_vcpkg_dlls: vcpkg installed directory not found. Tried:")
        message(WARNING "  - ${CMAKE_BINARY_DIR}/vcpkg_installed/${VCPKG_TARGET_TRIPLET}")
        message(WARNING "  - ${VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}")
        return()
    endif()

    # Add the custom command to copy DLLs after building the target
    add_custom_command(TARGET ${target_name} POST_BUILD
        COMMAND powershell -noprofile -executionpolicy Bypass -file "${VCPKG_APPLOCAL_SCRIPT}"
            -targetBinary "$<TARGET_FILE:${target_name}>"
            -installedDir "${VCPKG_INSTALLED_DIR}"
        COMMENT "Copying vcpkg DLLs for ${target_name}"
        VERBATIM
    )

    # Store information for debugging
    set_target_properties(${target_name} PROPERTIES
        VCPKG_DLL_COPYING_ENABLED TRUE
        VCPKG_APPLOCAL_SCRIPT "${VCPKG_APPLOCAL_SCRIPT}"
        VCPKG_INSTALLED_DIR "${VCPKG_INSTALLED_DIR}"
    )

    message(STATUS "copy_vcpkg_dlls: Enabled DLL copying for target '${target_name}'")
endfunction()

# Function to enable vcpkg DLL copying globally for all executables in the project
#
# This function sets up global properties to enable automatic DLL copying
# for all executable targets created after this function is called.
#
# Usage:
#   enable_vcpkg_dll_copying()
#
function(enable_vcpkg_dll_copying)
    if(NOT WIN32 OR NOT DEFINED CMAKE_TOOLCHAIN_FILE)
        return()
    endif()

    # Set global properties for Visual Studio generator
    if(CMAKE_GENERATOR MATCHES "Visual Studio")
        set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD ON PARENT_SCOPE)
        set(X_VCPKG_APPLOCAL_DEPS_INSTALL ON PARENT_SCOPE)
        message(STATUS "enable_vcpkg_dll_copying: Enabled global vcpkg DLL copying for Visual Studio")
    endif()

    # Set a global property to track that this has been called
    set_property(GLOBAL PROPERTY VCPKG_DLL_COPYING_GLOBALLY_ENABLED TRUE)
endfunction()

# Function to check if vcpkg DLL copying is available
#
# This function checks if the current environment supports vcpkg DLL copying
# and returns the result in the specified variable.
#
# Usage:
#   is_vcpkg_dll_copying_available(result_var)
#
# Parameters:
#   result_var - Variable to store the result (TRUE/FALSE)
#
function(is_vcpkg_dll_copying_available result_var)
    set(${result_var} FALSE PARENT_SCOPE)

    if(NOT WIN32)
        return()
    endif()

    if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
        return()
    endif()

    # Find vcpkg root and check for applocal.ps1
    get_filename_component(VCPKG_ROOT_DIR ${CMAKE_TOOLCHAIN_FILE} DIRECTORY)
    get_filename_component(VCPKG_ROOT_DIR ${VCPKG_ROOT_DIR} DIRECTORY)
    get_filename_component(VCPKG_ROOT_DIR ${VCPKG_ROOT_DIR} DIRECTORY)
    
    set(VCPKG_APPLOCAL_SCRIPT "${VCPKG_ROOT_DIR}/scripts/buildsystems/msbuild/applocal.ps1")
    
    if(EXISTS ${VCPKG_APPLOCAL_SCRIPT})
        set(${result_var} TRUE PARENT_SCOPE)
    endif()
endfunction()

# Function to get information about vcpkg DLL copying setup
#
# This function provides diagnostic information about the vcpkg DLL copying
# configuration for debugging purposes.
#
# Usage:
#   get_vcpkg_dll_info()
#
function(get_vcpkg_dll_info)
    message(STATUS "=== vcpkg DLL Copying Information ===")
    
    if(WIN32)
        message(STATUS "Platform: Windows (DLL copying applicable)")
    else()
        message(STATUS "Platform: Non-Windows (DLL copying not needed)")
        return()
    endif()

    if(DEFINED CMAKE_TOOLCHAIN_FILE)
        message(STATUS "vcpkg toolchain: ${CMAKE_TOOLCHAIN_FILE}")
        
        # Find vcpkg root
        get_filename_component(VCPKG_ROOT_DIR ${CMAKE_TOOLCHAIN_FILE} DIRECTORY)
        get_filename_component(VCPKG_ROOT_DIR ${VCPKG_ROOT_DIR} DIRECTORY)
        get_filename_component(VCPKG_ROOT_DIR ${VCPKG_ROOT_DIR} DIRECTORY)
        message(STATUS "vcpkg root: ${VCPKG_ROOT_DIR}")
        
        # Check applocal script
        set(VCPKG_APPLOCAL_SCRIPT "${VCPKG_ROOT_DIR}/scripts/buildsystems/msbuild/applocal.ps1")
        if(EXISTS ${VCPKG_APPLOCAL_SCRIPT})
            message(STATUS "applocal.ps1: Found")
        else()
            message(STATUS "applocal.ps1: NOT FOUND at ${VCPKG_APPLOCAL_SCRIPT}")
        endif()
        
        # Show triplet
        if(DEFINED VCPKG_TARGET_TRIPLET)
            message(STATUS "Target triplet: ${VCPKG_TARGET_TRIPLET}")
        else()
            message(STATUS "Target triplet: Not defined (will auto-detect)")
        endif()
    else()
        message(STATUS "vcpkg toolchain: Not defined")
    endif()
    
    # Check global settings
    get_property(globally_enabled GLOBAL PROPERTY VCPKG_DLL_COPYING_GLOBALLY_ENABLED)
    if(globally_enabled)
        message(STATUS "Global DLL copying: Enabled")
    else()
        message(STATUS "Global DLL copying: Not enabled")
    endif()
    
    message(STATUS "=====================================")
endfunction()

# Print a helpful message when this module is included
message(STATUS "VcpkgUtils.cmake: vcpkg utility functions loaded")