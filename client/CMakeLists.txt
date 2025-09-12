cmake_minimum_required(VERSION 3.21)

# Client CMakeLists.txt
project(cpplib_demo)

# Create demo executable
add_executable(cpplib_demo main.cpp)

# Link with the library
target_link_libraries(cpplib_demo PRIVATE cpplib)

# Set output directory
set_target_properties(cpplib_demo PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Copy vcpkg DLLs to the output directory
copy_vcpkg_dlls(cpplib_demo)

# Install the demo executable (optional)
install(TARGETS cpplib_demo
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
