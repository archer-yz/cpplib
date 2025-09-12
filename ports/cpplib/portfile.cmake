vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://github.com/example/cpplib.git
    REF v1.0.0
    SHA512 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCPPLIB_BUILD_EXAMPLES=OFF
        -DCPPLIB_BUILD_TESTS=OFF
)

vcpkg_cmake_build()

vcpkg_cmake_install()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Remove duplicate files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle CMake config
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cpplib)

# Copy usage file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Check that the expected files are present
vcpkg_list(SET EXPECTED_TOOLS)
if("tools" IN_LIST FEATURES)
    vcpkg_list(APPEND EXPECTED_TOOLS cpplib_demo)
endif()

if(EXPECTED_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES ${EXPECTED_TOOLS} AUTO_CLEAN)
