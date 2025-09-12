# Handling vcpkg DLL Dependencies

This document explains how to handle the common issue where vcpkg DLLs are not automatically copied to the executable output directory, causing runtime failures.

## Problem Description

When using vcpkg dependencies that provide shared libraries (DLLs on Windows), the DLL files are not automatically copied to the executable's output directory. This causes the executable to fail at runtime with "DLL not found" errors.

## Solutions Implemented

### Solution 1: vcpkg Built-in DLL Copying (Recommended)

#### In Main CMakeLists.txt:

```cmake
# Include vcpkg toolchain if available
if(DEFINED CMAKE_TOOLCHAIN_FILE)
    message(STATUS "Using vcpkg toolchain: ${CMAKE_TOOLCHAIN_FILE}")

    # Enable vcpkg DLL copying on Windows
    if(WIN32)
        set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD 1)
        # This will copy vcpkg DLLs to the output directory
        set(X_VCPKG_APPLOCAL_DEPS_INSTALL ON)
    endif()
endif()
```

#### In Executable CMakeLists.txt:

```cmake
# Copy vcpkg DLLs to the output directory on Windows
if(WIN32 AND DEFINED CMAKE_TOOLCHAIN_FILE)
    # Enable vcpkg DLL copying for this target
    set_target_properties(target_name PROPERTIES
        VS_GLOBAL_VcpkgEnabled true
    )

    # Use vcpkg's applocal.ps1 script to copy DLLs
    if(CMAKE_GENERATOR MATCHES "Visual Studio")
        set_target_properties(target_name PROPERTIES
            VS_GLOBAL_VcpkgAppLocalDeps true
        )
    endif()
endif()
```

### Solution 2: Custom DLL Copying Function

#### Custom Function Definition:

```cmake
# Function to copy DLLs for Windows executables
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

#### Usage:

```cmake
# After creating the executable target
copy_vcpkg_dlls(my_executable)
```

## Implementation Results

After implementing these solutions, the following DLLs are automatically copied:

### Static Library Build:

- `fmt.dll` → copied to `build/vs2022/bin/Release/`
- Executable runs without manual DLL copying

### Shared Library Build:

- `fmt.dll` → copied to `build/vs2022-shared/bin/Release/`
- `cpplib.dll` → already in the output directory
- Executable runs without manual DLL copying

### Test Consumer Project:

- `fmt.dll` → copied to `test_consumer/build/Release/`
- Executable runs without manual DLL copying

## Build Output Verification

When the DLL copying is working correctly, you should see messages like:

```
Copying vcpkg DLLs for target_name
```

## Benefits

1. **Automatic**: No manual DLL copying required
2. **Cross-platform**: Only activates on Windows where needed
3. **Robust**: Uses vcpkg's official applocal.ps1 script
4. **Maintainable**: Centralized function that can be reused across projects
5. **Development-friendly**: Enables running executables directly from build directory

## Alternative Solutions

### Manual Copying (Not Recommended):

```cmake
# Manual copy - brittle and requires maintenance
if(WIN32)
    add_custom_command(TARGET my_target POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${VCPKG_ROOT}/installed/${VCPKG_TARGET_TRIPLET}/bin/fmt.dll"
            $<TARGET_FILE_DIR:my_target>)
endif()
```

### Static Linking:

```cmake
# Use header-only or static versions when available
find_package(fmt CONFIG REQUIRED)
target_link_libraries(my_target PRIVATE fmt::fmt-header-only)
```

## Best Practices

1. Always use the custom function approach for maximum compatibility
2. Include the function in a shared CMake utilities file for reuse
3. Test both Debug and Release configurations
4. Verify DLL copying works in CI/CD environments
5. Document the DLL copying behavior for other developers

## Troubleshooting

### DLLs Not Copied:

- Verify `CMAKE_TOOLCHAIN_FILE` is set correctly
- Check that the vcpkg applocal.ps1 script exists
- Ensure PowerShell execution policy allows script execution

### Wrong DLLs Copied:

- Verify `VCPKG_TARGET_TRIPLET` matches your build configuration
- Check that vcpkg dependencies are properly installed

### Performance Issues:

- DLL copying only happens when DLLs are newer than target
- Consider using static linking for final distribution builds
