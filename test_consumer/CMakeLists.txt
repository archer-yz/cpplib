cmake_minimum_required(VERSION 3.21)
project(test_consumer VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Include vcpkg utilities
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}")
include(VcpkgUtils)

# Find the installed cpplib package
find_package(cpplib CONFIG REQUIRED)

# Create a simple test executable
add_executable(test_consumer main.cpp)

# Link against the installed library
target_link_libraries(test_consumer PRIVATE cpplib::cpplib)

# Copy vcpkg DLLs to the output directory
copy_vcpkg_dlls(test_consumer)

# Print some information
message(STATUS "Found cpplib version: ${cpplib_VERSION}")
message(STATUS "Using cpplib targets: ${cpplib_LIBRARIES}")
