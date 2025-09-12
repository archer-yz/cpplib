# CMake Utility Modules Best Practices

This document explains the benefits of using CMake utility modules and demonstrates how to create reusable, maintainable CMake code.

## Overview

Instead of duplicating CMake functions across different projects or even within the same project, it's a best practice to create utility modules that can be included and reused.

## Benefits of Using Utility Modules

### 1. **Code Reusability**

- Write once, use everywhere
- No need to copy-paste functions between projects
- Consistent implementation across all projects

### 2. **Maintainability**

- Single source of truth for utility functions
- Bugs fixed in one place benefit all consumers
- Easy to add features and improvements

### 3. **Documentation**

- Centralized documentation for utility functions
- Clear function signatures and parameters
- Examples and usage patterns in one place

### 4. **Testing**

- Utility functions can be independently tested
- Validation and error handling in one place
- Consistent behavior across projects

### 5. **Version Control**

- Utility modules can be versioned independently
- Easy to track changes and improvements
- Can be shared across teams and organizations

## Implementation Example: VcpkgUtils.cmake

### Before (Duplicated Code)

```cmake
# In every CMakeLists.txt that needs DLL copying
function(copy_vcpkg_dlls target_name)
    if(WIN32 AND CMAKE_TOOLCHAIN_FILE)
        # Find vcpkg applocal.ps1 script
        get_filename_component(VCPKG_ROOT_DIR ${CMAKE_TOOLCHAIN_FILE} DIRECTORY)
        get_filename_component(VCPKG_ROOT_DIR ${VCPKG_ROOT_DIR} DIRECTORY)
        get_filename_component(VCPKG_ROOT_DIR ${VCPKG_ROOT_DIR} DIRECTORY)
        set(VCPKG_APPLOCAL_SCRIPT "${VCPKG_ROOT_DIR}/scripts/buildsystems/msbuild/applocal.ps1")

        if(EXISTS ${VCPKG_APPLOCAL_SCRIPT})
            add_custom_command(TARGET ${target_name} POST_BUILD
                COMMAND powershell -noprofile -executionpolicy Bypass -file ${VCPKG_APPLOCAL_SCRIPT}
                    -targetBinary $<TARGET_FILE:${target_name}>
                    -installedDir "${VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}"
                COMMENT "Copying vcpkg DLLs for ${target_name}")
        endif()
    endif()
endfunction()
```

### After (Utility Module)

```cmake
# In main CMakeLists.txt
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(VcpkgUtils)

# In any executable CMakeLists.txt
copy_vcpkg_dlls(my_target)
```

## Project Structure

```
project/
├── cmake/
│   ├── VcpkgUtils.cmake       # vcpkg-related utilities
│   ├── CompilerUtils.cmake    # Compiler-specific utilities
│   └── TestUtils.cmake        # Testing utilities
├── src/
├── include/
├── client/
│   └── CMakeLists.txt         # Uses: copy_vcpkg_dlls(client_exe)
├── tests/
│   └── CMakeLists.txt         # Uses: copy_vcpkg_dlls(test_exe)
└── CMakeLists.txt             # Includes utility modules
```

## VcpkgUtils.cmake Features

### Functions Provided

1. **`copy_vcpkg_dlls(target_name)`** - Copy DLLs to executable directory
2. **`enable_vcpkg_dll_copying()`** - Enable global DLL copying
3. **`is_vcpkg_dll_copying_available(result_var)`** - Check availability
4. **`get_vcpkg_dll_info()`** - Print diagnostic information

### Advanced Features

- **Error Validation**: Checks if target exists and is an executable
- **Auto-Detection**: Automatically detects vcpkg triplet if not set
- **Local vs Global**: Tries local vcpkg_installed first, then global
- **Diagnostic Info**: Provides detailed information for debugging
- **Include Guard**: Prevents multiple inclusions

### Usage Examples

```cmake
# Basic usage
copy_vcpkg_dlls(my_executable)

# Check if available before using
is_vcpkg_dll_copying_available(can_copy_dlls)
if(can_copy_dlls)
    copy_vcpkg_dlls(my_executable)
endif()

# Get diagnostic information
get_vcpkg_dll_info()
```

## Distribution Strategies

### 1. **Project-Local Modules**

```cmake
# Store in project's cmake/ directory
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(VcpkgUtils)
```

### 2. **Shared Modules (Git Submodule)**

```cmake
# Store in shared repository, include as submodule
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/external/cmake-utils")
include(VcpkgUtils)
```

### 3. **System-Wide Installation**

```cmake
# Install to CMAKE_MODULE_PATH
find_package(VcpkgUtils REQUIRED)
```

### 4. **vcpkg Port**

```cmake
# Distribute as vcpkg port
find_package(cmake-vcpkg-utils CONFIG REQUIRED)
```

## Best Practices for Utility Modules

### 1. **Use Include Guards**

```cmake
include_guard(GLOBAL)  # Prevent multiple inclusions
```

### 2. **Validate Parameters**

```cmake
function(my_function target_name)
    if(NOT TARGET ${target_name})
        message(FATAL_ERROR "Target '${target_name}' does not exist")
    endif()
endfunction()
```

### 3. **Provide Documentation**

```cmake
# Function to copy vcpkg DLLs to the target's output directory
#
# Usage:
#   copy_vcpkg_dlls(target_name)
#
# Parameters:
#   target_name - The name of the executable target
```

### 4. **Handle Cross-Platform**

```cmake
function(my_function target_name)
    if(NOT WIN32)
        return()  # Only relevant on Windows
    endif()
endfunction()
```

### 5. **Provide Diagnostic Functions**

```cmake
function(get_module_info)
    message(STATUS "=== Module Information ===")
    # Print relevant diagnostic info
endfunction()
```

## Testing Utility Modules

### Unit Testing

```cmake
# Test individual functions
include(VcpkgUtils)

# Test function exists
if(NOT COMMAND copy_vcpkg_dlls)
    message(FATAL_ERROR "copy_vcpkg_dlls function not found")
endif()

# Test with invalid target
copy_vcpkg_dlls(non_existent_target)  # Should warn, not fail
```

### Integration Testing

```cmake
# Test in real project context
add_executable(test_exe test.cpp)
copy_vcpkg_dlls(test_exe)
# Verify DLLs are copied after build
```

## Migration Guide

### Step 1: Create Utility Module

```cmake
# cmake/VcpkgUtils.cmake
include_guard(GLOBAL)
function(copy_vcpkg_dlls target_name)
    # Implementation here
endfunction()
```

### Step 2: Update Main CMakeLists.txt

```cmake
# Add to CMAKE_MODULE_PATH and include
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(VcpkgUtils)
```

### Step 3: Replace Inline Functions

```cmake
# Before:
function(copy_vcpkg_dlls target_name)
    # Inline implementation
endfunction()
copy_vcpkg_dlls(my_target)

# After:
copy_vcpkg_dlls(my_target)  # Function comes from utility module
```

### Step 4: Update All Consumers

```cmake
# In client/CMakeLists.txt, tests/CMakeLists.txt, etc.
copy_vcpkg_dlls(target_name)  # Clean, simple usage
```

## Conclusion

Using utility modules transforms CMake codebases from repetitive, error-prone implementations to clean, maintainable, and reusable solutions. The `VcpkgUtils.cmake` module demonstrates how a complex, platform-specific task can be encapsulated into a simple, reliable function that can be used across any project.

### Key Takeaways

- **Invest time in utilities**: The upfront cost pays dividends in maintenance
- **Make them robust**: Handle edge cases and provide good error messages
- **Document thoroughly**: Future developers will thank you
- **Test extensively**: Utility modules are used everywhere, so they must be reliable
- **Version carefully**: Changes to utilities affect all consumers
