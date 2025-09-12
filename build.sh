#!/bin/bash
# Build script for CPPLib on Linux/macOS
#
# NOTE: This project also supports CMake presets for easier configuration:
#   export VCPKG_ROOT=/path/to/vcpkg
#   cmake --preset default-linux  # or default-macos
#   cmake --build --preset default
#
# Run "cmake --list-presets" to see all available presets.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_TYPE="Release"
LIBRARY_TYPE="static"
VCPKG_ROOT=""

# Function to show help
show_help() {
    cat << EOF
CPPLib Build Script

Usage: $0 [options]

Options:
  --shared          Build shared library (default: static)
  --debug           Build debug version (default: release)
  --vcpkg-root PATH Specify vcpkg installation directory
  --help            Show this help message

Examples:
  $0                        # Build static release library
  $0 --shared               # Build shared release library
  $0 --debug                # Build static debug library
  $0 --shared --debug       # Build shared debug library
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --shared)
            LIBRARY_TYPE="shared"
            shift
            ;;
        --debug)
            BUILD_TYPE="Debug"
            shift
            ;;
        --vcpkg-root)
            VCPKG_ROOT="$2"
            shift 2
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown argument: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check for vcpkg
if [[ -z "$VCPKG_ROOT" ]]; then
    if [[ -f "$HOME/vcpkg/scripts/buildsystems/vcpkg.cmake" ]]; then
        VCPKG_ROOT="$HOME/vcpkg"
    elif [[ -f "./vcpkg/scripts/buildsystems/vcpkg.cmake" ]]; then
        VCPKG_ROOT="./vcpkg"
    elif [[ -f "/usr/local/share/vcpkg/scripts/buildsystems/vcpkg.cmake" ]]; then
        VCPKG_ROOT="/usr/local/share/vcpkg"
    else
        echo "Error: vcpkg not found. Please specify --vcpkg-root or install vcpkg"
        exit 1
    fi
fi

TOOLCHAIN_FILE="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake"
if [[ ! -f "$TOOLCHAIN_FILE" ]]; then
    echo "Error: vcpkg toolchain file not found at $TOOLCHAIN_FILE"
    exit 1
fi

echo "================================="
echo "Building CPPLib"
echo "================================="
echo "Build Type: $BUILD_TYPE"
echo "Library Type: $LIBRARY_TYPE"
echo "vcpkg Root: $VCPKG_ROOT"
echo "================================="

# Set build directory based on library type
if [[ "$LIBRARY_TYPE" == "shared" ]]; then
    BUILD_DIR="build-shared"
    SHARED_LIBS_FLAG="-DBUILD_SHARED_LIBS=ON"
else
    BUILD_DIR="build"
    SHARED_LIBS_FLAG=""
fi

# Configure
echo "Configuring..."
cmake -B "$BUILD_DIR" -S . \
    -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE" \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    $SHARED_LIBS_FLAG

# Build
echo "Building..."
cmake --build "$BUILD_DIR"

echo "================================="
echo "Build completed successfully!"
echo "================================="
echo "Executable: $BUILD_DIR/bin/cpplib_demo"
echo "Library: $BUILD_DIR/lib/"

echo ""
echo "To run the demo:"
echo "  $BUILD_DIR/bin/cpplib_demo"
