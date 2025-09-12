cmake_minimum_required(VERSION 3.21)

# Set project name and version
project(cpplib
    VERSION 1.0.0
    DESCRIPTION "Demo C++ library showcasing static/dynamic library development"
    LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Add compiler-specific options
if(MSVC)
    add_compile_options(/W4)
    # Enable proper C++ exception handling
    add_compile_options(/EHsc)
else()
    add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# Options for library type
option(BUILD_SHARED_LIBS "Build shared libraries instead of static" OFF)
option(CPPLIB_BUILD_EXAMPLES "Build example applications" ON)
option(CPPLIB_BUILD_TESTS "Build tests" OFF)

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

# Include vcpkg utilities
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(VcpkgUtils)

# Find required packages
find_package(fmt CONFIG REQUIRED)

# Include necessary CMake modules
include(GenerateExportHeader)

# Include directories
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

# Define library sources
set(CPPLIB_SOURCES
    src/cpplib.cpp
)

set(CPPLIB_HEADERS
    include/cpplib/cpplib.h
)

# Create the library
if(BUILD_SHARED_LIBS)
    add_library(cpplib SHARED ${CPPLIB_SOURCES} ${CPPLIB_HEADERS})

    # Set Windows-specific properties for DLL
    if(WIN32)
        set_target_properties(cpplib PROPERTIES
            WINDOWS_EXPORT_ALL_SYMBOLS OFF  # We use explicit exports
            RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
            LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
            ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
        )
    endif()
else()
    add_library(cpplib STATIC ${CPPLIB_SOURCES} ${CPPLIB_HEADERS})
endif()# Set target properties
set_target_properties(cpplib PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
    PUBLIC_HEADER "${CPPLIB_HEADERS}"
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN ON
    DEFINE_SYMBOL "cpplib_EXPORTS"  # This is important for export header generation
)

# Generate export header automatically (must be after add_library)
generate_export_header(cpplib
    EXPORT_FILE_NAME ${CMAKE_CURRENT_BINARY_DIR}/include/cpplib/export.h
    BASE_NAME CPPLIB
    EXPORT_MACRO_NAME CPPLIB_EXPORT
    NO_EXPORT_MACRO_NAME CPPLIB_NO_EXPORT
    STATIC_DEFINE CPPLIB_STATIC
    DEPRECATED_MACRO_NAME CPPLIB_DEPRECATED
)

# Ensure static library consumers get the CPPLIB_STATIC define
if(NOT BUILD_SHARED_LIBS)
    target_compile_definitions(cpplib PUBLIC CPPLIB_STATIC)
endif()

# Link libraries
target_link_libraries(cpplib PUBLIC fmt::fmt)

# Enable position independent code for static libraries
if(NOT BUILD_SHARED_LIBS)
    set_target_properties(cpplib PROPERTIES POSITION_INDEPENDENT_CODE ON)
endif()

# Platform-specific configurations
if(WIN32)
    # Windows-specific settings
    if(MSVC)
        target_compile_options(cpplib PRIVATE /bigobj)
    endif()
elseif(APPLE)
    # macOS-specific settings
    set_target_properties(cpplib PROPERTIES
        MACOSX_RPATH ON
        INSTALL_RPATH_USE_LINK_PATH ON
    )
elseif(UNIX)
    # Linux-specific settings
    set_target_properties(cpplib PROPERTIES
        INSTALL_RPATH_USE_LINK_PATH ON
    )
endif()

# Add client example if requested
if(CPPLIB_BUILD_EXAMPLES)
    add_subdirectory(client)
endif()

# Add tests if requested
if(CPPLIB_BUILD_TESTS)
    enable_testing()
    find_package(GTest CONFIG REQUIRED)
    add_subdirectory(tests)
endif()

# Installation configuration
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# Add the generated include directory
target_include_directories(cpplib
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)

# Install targets
install(TARGETS cpplib
    EXPORT cpplibTargets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/cpplib
)

# Install headers
install(DIRECTORY include/cpplib
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h"
)

# Install the generated export header
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/include/cpplib/export.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/cpplib
)

# Create and install package config files
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/cpplibConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cpplibConfig.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/cpplib
)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/cpplibConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/cpplibConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/cpplibConfigVersion.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/cpplib
)

# Install export targets
install(EXPORT cpplibTargets
    FILE cpplibTargets.cmake
    NAMESPACE cpplib::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/cpplib
)

# Generate export file for build tree
export(EXPORT cpplibTargets
    FILE "${CMAKE_CURRENT_BINARY_DIR}/cpplibTargets.cmake"
    NAMESPACE cpplib::
)

# Print configuration summary
message(STATUS "=== CPPLib Configuration ===")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
if(BUILD_SHARED_LIBS)
    message(STATUS "Library type: SHARED")
else()
    message(STATUS "Library type: STATIC")
endif()
message(STATUS "C++ standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "Install prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "Examples: ${CPPLIB_BUILD_EXAMPLES}")
message(STATUS "Tests: ${CPPLIB_BUILD_TESTS}")
