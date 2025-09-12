#!/bin/bash
# CMake Presets demonstration script for Linux/macOS

set -e

echo "=============================================="
echo "CPPLib CMake Presets Demo"
echo "=============================================="

# Check if VCPKG_ROOT is set
if [[ -z "$VCPKG_ROOT" ]]; then
    echo "Warning: VCPKG_ROOT environment variable is not set."
    echo "Please set it to your vcpkg installation directory:"
    echo "  export VCPKG_ROOT=/path/to/vcpkg"
    echo ""
    echo "Attempting to find vcpkg automatically..."

    if [[ -f "$HOME/vcpkg/scripts/buildsystems/vcpkg.cmake" ]]; then
        export VCPKG_ROOT="$HOME/vcpkg"
        echo "Found vcpkg at $HOME/vcpkg"
    elif [[ -f "./vcpkg/scripts/buildsystems/vcpkg.cmake" ]]; then
        export VCPKG_ROOT="./vcpkg"
        echo "Found vcpkg at ./vcpkg"
    elif [[ -f "/usr/local/share/vcpkg/scripts/buildsystems/vcpkg.cmake" ]]; then
        export VCPKG_ROOT="/usr/local/share/vcpkg"
        echo "Found vcpkg at /usr/local/share/vcpkg"
    else
        echo "Error: Could not find vcpkg. Please install and set VCPKG_ROOT."
        exit 1
    fi
    echo ""
fi

echo "Using VCPKG_ROOT: $VCPKG_ROOT"
echo ""

echo "Available configure presets:"
cmake --list-presets=configure
echo ""

echo "Available build presets:"
cmake --list-presets=build
echo ""

echo "Available test presets:"
cmake --list-presets=test
echo ""

echo "=============================================="
echo "Quick Demo - Building with appropriate preset"
echo "=============================================="

# Determine the appropriate default preset
if [[ "$OSTYPE" == "darwin"* ]]; then
    PRESET="default-macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PRESET="default-linux"
else
    PRESET="default"
fi

echo "Configuring with $PRESET preset..."
cmake --preset "$PRESET"

echo ""
echo "Building with default preset..."
cmake --build --preset default

echo ""
echo "=============================================="
echo "Build completed successfully!"
echo "=============================================="
echo ""
echo "You can now run:"
echo "  ./build/default/bin/cpplib_demo"
echo ""
echo "Other useful commands:"
echo "  cmake --preset shared-release      # Shared library build"
echo "  cmake --preset clang               # Clang compiler"
echo "  cmake --preset sanitizers          # With sanitizers"
echo "  cmake --workflow --preset full-build    # Complete workflow"
echo ""
