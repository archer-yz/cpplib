@echo off
REM Build script for CPPLib on Windows
REM
REM NOTE: This project also supports CMake presets for easier configuration:
REM   set VCPKG_ROOT=C:\path\to\vcpkg
REM   cmake --preset default
REM   cmake --build --preset default
REM
REM Run "cmake --list-presets" to see all available presets.

setlocal

set "SCRIPT_DIR=%~dp0"
set "BUILD_TYPE=Release"
set "LIBRARY_TYPE=static"
set "VCPKG_ROOT="

REM Parse command line arguments
:parse_args
if "%~1"=="" goto :done_parsing
if /i "%~1"=="--shared" (
    set "LIBRARY_TYPE=shared"
    shift
    goto :parse_args
)
if /i "%~1"=="--debug" (
    set "BUILD_TYPE=Debug"
    shift
    goto :parse_args
)
if /i "%~1"=="--vcpkg-root" (
    set "VCPKG_ROOT=%~2"
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="--help" (
    goto :show_help
)
echo Unknown argument: %~1
goto :show_help

:done_parsing

REM Check for vcpkg
if "%VCPKG_ROOT%"=="" (
    if exist "C:\vcpkg\scripts\buildsystems\vcpkg.cmake" (
        set "VCPKG_ROOT=C:\vcpkg"
    ) else if exist "vcpkg\scripts\buildsystems\vcpkg.cmake" (
        set "VCPKG_ROOT=vcpkg"
    ) else (
        echo Error: vcpkg not found. Please specify --vcpkg-root or install vcpkg
        exit /b 1
    )
)

set "TOOLCHAIN_FILE=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake"
if not exist "%TOOLCHAIN_FILE%" (
    echo Error: vcpkg toolchain file not found at %TOOLCHAIN_FILE%
    exit /b 1
)

echo =================================
echo Building CPPLib
echo =================================
echo Build Type: %BUILD_TYPE%
echo Library Type: %LIBRARY_TYPE%
echo vcpkg Root: %VCPKG_ROOT%
echo =================================

REM Set build directory based on library type
if "%LIBRARY_TYPE%"=="shared" (
    set "BUILD_DIR=build-shared"
    set "SHARED_LIBS_FLAG=-DBUILD_SHARED_LIBS=ON"
) else (
    set "BUILD_DIR=build"
    set "SHARED_LIBS_FLAG="
)

REM Configure
echo Configuring...
cmake -B "%BUILD_DIR%" -S . ^
    -DCMAKE_TOOLCHAIN_FILE="%TOOLCHAIN_FILE%" ^
    -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
    %SHARED_LIBS_FLAG%

if errorlevel 1 (
    echo Configuration failed!
    exit /b 1
)

REM Build
echo Building...
cmake --build "%BUILD_DIR%" --config %BUILD_TYPE%

if errorlevel 1 (
    echo Build failed!
    exit /b 1
)

echo =================================
echo Build completed successfully!
echo =================================
echo Executable: %BUILD_DIR%\bin\%BUILD_TYPE%\cpplib_demo.exe
echo Library: %BUILD_DIR%\lib\%BUILD_TYPE%\

echo.
echo To run the demo:
echo   %BUILD_DIR%\bin\%BUILD_TYPE%\cpplib_demo.exe
goto :eof

:show_help
echo CPPLib Build Script
echo.
echo Usage: %~n0 [options]
echo.
echo Options:
echo   --shared          Build shared library (default: static)
echo   --debug           Build debug version (default: release)
echo   --vcpkg-root PATH Specify vcpkg installation directory
echo   --help            Show this help message
echo.
echo Examples:
echo   %~n0                        # Build static release library
echo   %~n0 --shared               # Build shared release library
echo   %~n0 --debug                # Build static debug library
echo   %~n0 --shared --debug       # Build shared debug library
goto :eof
