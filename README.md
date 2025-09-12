# CPPLib - Demo C++ Library Project

A comprehensive demonstration of C++ static and dynamic library development using vcpkg and CMake. This project showcases best practices for cross-platform library development, packaging, and distribution.

## Features

- **Cross-platform compatibility** (Windows, Linux, macOS)
- **Static and dynamic library support** with CMake options
- **vcpkg integration** for dependency management
- **Modern C++17** with proper API design
- **Export/import macros** for Windows DLL support
- **CMake package configuration** for easy integration
- **vcpkg port** for distribution
- **Comprehensive examples** and documentation

## Project Structure

```
cpplib/
├── include/cpplib/          # Public headers
│   ├── cpplib.h            # Main API header
│   ├── cpplib_impl.h       # Template implementations
│   └── export.h            # Generated export macros (build-time)
├── src/                     # Library source files
│   └── cpplib.cpp          # Core implementation
├── client/                  # Built-in demo application
│   ├── CMakeLists.txt      # Client build configuration
│   └── main.cpp            # Demo showcasing library features
├── test_consumer/           # External consumer example
│   ├── CMakeLists.txt      # Standalone project using installed library
│   ├── main.cpp            # Usage example
│   ├── vcpkg.json          # Consumer dependencies
│   └── VcpkgUtils.cmake    # Utility module copy
├── cmake/                   # CMake modules and configuration
│   ├── VcpkgUtils.cmake    # vcpkg utilities (DLL copying, etc.)
│   └── cpplibConfig.cmake.in # Package config template
├── docs/                    # Documentation
│   ├── DLL_HANDLING.md     # vcpkg DLL solutions guide
│   └── CMAKE_UTILITIES.md  # CMake best practices guide
├── ports/cpplib/           # vcpkg port files for distribution
│   ├── portfile.cmake      # vcpkg build instructions
│   ├── vcpkg.json          # Port manifest
│   └── usage               # Usage documentation
├── CMakeLists.txt          # Main build configuration
├── CMakePresets.json       # 34+ build presets for different scenarios
├── vcpkg.json              # vcpkg manifest for dependencies
├── vcpkg-configuration.json # vcpkg configuration
├── build.bat/.sh           # Quick build scripts
├── demo-presets.bat/.sh    # Preset demonstration scripts
└── README.md               # This file
```

## Library Features

### StringFormatter Class

- Format strings using the fmt library
- Timestamped logging functionality
- Exception-safe formatting
- Version and build type information

### MathUtils Class

- Factorial calculation
- Prime number checking
- Fibonacci sequence generation

## Prerequisites

- **CMake** 3.21 or higher
- **vcpkg** (for dependency management)
- **C++17 compatible compiler**:
  - Visual Studio 2019+ (Windows)
  - GCC 8+ (Linux)
  - Clang 8+ (macOS/Linux)

## Quick Start

### 1. Clone and Setup vcpkg

```bash
# Install vcpkg (if not already installed)
git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
./bootstrap-vcpkg.sh  # Linux/macOS
# or
./bootstrap-vcpkg.bat  # Windows
```

### 2. Build the Library

#### Quick Demo Scripts

For a quick demonstration of CMake presets:

```bash
# Windows
demo-presets.bat

# Linux/macOS
chmod +x demo-presets.sh
./demo-presets.sh
```

These scripts will automatically detect vcpkg, list available presets, and build a debug version of the library.

#### Using CMake Presets (Recommended)

The project includes comprehensive CMake presets for easy configuration:

```bash
# Set VCPKG_ROOT environment variable
export VCPKG_ROOT=/path/to/vcpkg  # Linux/macOS
set VCPKG_ROOT=C:\path\to\vcpkg   # Windows

# List available presets
cmake --list-presets

# Configure and build using presets
cmake --preset default           # Default configuration
cmake --build --preset default   # Build

# Other useful presets
cmake --preset debug             # Debug build
cmake --preset shared-release    # Shared library release
cmake --preset vs2022            # Visual Studio 2022 (Windows)
cmake --preset clang             # Clang compiler (Linux/macOS)
```

#### Manual Configuration

#### Windows (Visual Studio)

```cmd
# Configure with vcpkg toolchain
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=[vcpkg-root]/scripts/buildsystems/vcpkg.cmake

# Build static library (default)
cmake --build build --config Release

# Or build dynamic library
cmake -B build-shared -S . -DBUILD_SHARED_LIBS=ON -DCMAKE_TOOLCHAIN_FILE=[vcpkg-root]/scripts/buildsystems/vcpkg.cmake
cmake --build build-shared --config Release
```

#### Linux/macOS

```bash
# Configure with vcpkg toolchain
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=[vcpkg-root]/scripts/buildsystems/vcpkg.cmake -DCMAKE_BUILD_TYPE=Release

# Build static library (default)
cmake --build build

# Or build dynamic library
cmake -B build-shared -S . -DBUILD_SHARED_LIBS=ON -DCMAKE_TOOLCHAIN_FILE=[vcpkg-root]/scripts/buildsystems/vcpkg.cmake -DCMAKE_BUILD_TYPE=Release
cmake --build build-shared
```

### 3. Run the Demo

#### Windows

```cmd
# Static library demo
./build/bin/Release/cpplib_demo.exe

# Dynamic library demo
./build-shared/bin/Release/cpplib_demo.exe
```

#### Linux/macOS

```bash
# Static library demo
./build/bin/cpplib_demo

# Dynamic library demo
./build-shared/bin/cpplib_demo
```

## CMake Options

| Option                  | Default | Description                              |
| ----------------------- | ------- | ---------------------------------------- |
| `BUILD_SHARED_LIBS`     | `OFF`   | Build shared libraries instead of static |
| `CPPLIB_BUILD_EXAMPLES` | `ON`    | Build example applications               |
| `CPPLIB_BUILD_TESTS`    | `OFF`   | Build unit tests                         |

## CMake Presets

The project includes comprehensive CMake presets for different build scenarios:

### Configure Presets

| Preset Name      | Description                            | Generator | Library Type | Build Type |
| ---------------- | -------------------------------------- | --------- | ------------ | ---------- |
| `default`        | Default Windows build with Ninja       | Ninja     | Static       | Release    |
| `default-linux`  | Default Linux build with Ninja         | Ninja     | Static       | Release    |
| `default-macos`  | Default macOS build with Ninja         | Ninja     | Static       | Release    |
| `debug`          | Debug build with tests enabled         | Ninja     | Static       | Debug      |
| `release`        | Optimized release build                | Ninja     | Static       | Release    |
| `shared-debug`   | Debug build with shared library        | Ninja     | Shared       | Debug      |
| `shared-release` | Release build with shared library      | Ninja     | Shared       | Release    |
| `vs2022`         | Visual Studio 2022 project             | VS 2022   | Static       | Multi      |
| `vs2022-shared`  | Visual Studio 2022 with shared library | VS 2022   | Shared       | Multi      |
| `mingw`          | MinGW compiler build                   | Ninja     | Static       | Release    |
| `clang`          | Clang compiler build                   | Ninja     | Static       | Release    |
| `sanitizers`     | Debug with AddressSanitizer/UBSan      | Ninja     | Static       | Debug      |
| `coverage`       | Debug with code coverage               | Ninja     | Static       | Debug      |
| `arm64`          | ARM64 cross-compilation                | Ninja     | Static       | Release    |

### Usage Examples

```bash
# Set vcpkg root environment variable
export VCPKG_ROOT=/path/to/vcpkg  # Linux/macOS
set VCPKG_ROOT=C:\path\to\vcpkg   # Windows

# List all available presets
cmake --list-presets=all

# Configure using a preset
cmake --preset debug
cmake --preset shared-release
cmake --preset vs2022

# Build using preset
cmake --build --preset debug
cmake --build --preset shared-release

# Run tests using preset
cmake --build --preset debug --target test
# or with CTest
ctest --preset default

# Create package
cpack --preset default

# Workflow presets (configure + build + test)
cmake --workflow --preset full-build
cmake --workflow --preset release-workflow
```

### Platform-Specific Examples

#### Windows with Visual Studio

```cmd
# Traditional Visual Studio workflow
cmake --preset vs2022
cmake --build --preset vs2022-release
```

#### Linux with different compilers

```bash
# GCC (default)
cmake --preset default-linux
cmake --build --preset default

# Clang
cmake --preset clang
cmake --build --preset clang

# With sanitizers
cmake --preset sanitizers
cmake --build --preset sanitizers
ctest --preset sanitizers
```

#### Development with code coverage

```bash
cmake --preset coverage
cmake --build --preset coverage
ctest --preset coverage
# Generate coverage report (requires lcov/gcov)
lcov --capture --directory build/coverage --output-file coverage.info
genhtml coverage.info --output-directory coverage-html
```

## Installation

### System Installation

```bash
# Configure and build
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=[vcpkg-root]/scripts/buildsystems/vcpkg.cmake -DCMAKE_BUILD_TYPE=Release

# Install to system directories
sudo cmake --install build  # Linux/macOS
# or
cmake --install build  # Windows (as Administrator)
```

### Custom Installation Prefix

```bash
cmake -B build -S . -DCMAKE_INSTALL_PREFIX=/path/to/install -DCMAKE_TOOLCHAIN_FILE=[vcpkg-root]/scripts/buildsystems/vcpkg.cmake
cmake --install build
```

## Using the Library in Your Project

### Example Projects Included

This project includes two different types of examples:

1. **`client/`** - Built-in Demo Application
   - Part of the main project build
   - Demonstrates library features during development
   - Built automatically when `CPPLIB_BUILD_EXAMPLES=ON`
   - Uses library directly from build tree

2. **`test_consumer/`** - External Consumer Example
   - Standalone project showing real-world usage
   - Demonstrates consuming the **installed** library
   - Has its own `vcpkg.json` for dependencies
   - Shows proper `find_package()` usage pattern
   - **This is the template for your own projects**

### With CMake find_package()

After installation, use the library in your CMake project (see `test_consumer/` for complete example):

```cmake
find_package(cpplib CONFIG REQUIRED)
target_link_libraries(your_target PRIVATE cpplib::cpplib)
```

### Example Usage

```cpp
#include <cpplib/cpplib.h>
#include <iostream>

int main() {
    // String formatting and logging
    cpplib::StringFormatter formatter;
    formatter.log("INFO", "Hello, {}! Number: {}", "World", 42);

    // Math utilities
    auto factorial = cpplib::MathUtils::factorial(10);
    auto fibonacci = cpplib::MathUtils::fibonacci(15);
    bool is_prime = cpplib::MathUtils::isPrime(17);

    std::cout << "Factorial of 10: " << factorial << std::endl;
    return 0;
}
```

## vcpkg Integration

### Using as a vcpkg Port

1. Copy the `ports/cpplib` directory to your vcpkg ports directory
2. Install the library:

```bash
vcpkg install cpplib
```

### Manifest Mode

Add to your `vcpkg.json`:

```json
{
  "dependencies": ["cpplib"]
}
```

## Compiler Support

### Windows

- **Visual Studio 2019** (16.0+) with MSVC v142
- **Visual Studio 2022** (17.0+) with MSVC v143
- **MinGW-w64** (GCC 8+)
- **Clang** 8+ with MSVC-like command line

### Linux

- **GCC** 8+
- **Clang** 8+

### macOS

- **Xcode** 10+ (Clang 8+)
- **Clang** 8+ (via Homebrew)

## Build Configurations

### Debug Build

```bash
cmake -B build-debug -S . -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE=[vcpkg-root]/scripts/buildsystems/vcpkg.cmake
cmake --build build-debug
```

### Release Build

```bash
cmake -B build-release -S . -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=[vcpkg-root]/scripts/buildsystems/vcpkg.cmake
cmake --build build-release
```

### Cross-compilation Example (ARM64)

```bash
# Example for ARM64 Linux
cmake -B build-arm64 -S . \
  -DCMAKE_TOOLCHAIN_FILE=[vcpkg-root]/scripts/buildsystems/vcpkg.cmake \
  -DVCPKG_TARGET_TRIPLET=arm64-linux \
  -DCMAKE_BUILD_TYPE=Release
```

## Troubleshooting

### vcpkg Issues

- Ensure vcpkg is properly bootstrapped
- Verify the toolchain file path is correct
- Check that fmt package is available: `vcpkg list fmt`

### Build Issues

- Ensure C++17 support is available
- Check CMake version (3.21+ required)
- Verify all dependencies are found during configuration

### Windows DLL Issues

- Ensure proper export/import macros are used
- Check that DLL is in PATH or same directory as executable
- Verify Windows SDK is installed for MSVC builds

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes following the coding style
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Dependencies

- **fmt** (>=9.0.0) - String formatting library
- **CMake** (>=3.21) - Build system
- **vcpkg** - Package manager

## Version History

- **1.0.0** - Initial release
  - Cross-platform static/dynamic library
  - vcpkg integration
  - Comprehensive examples and documentation
