@echo off
REM CMake Presets demonstration script for Windows

setlocal

echo ==============================================
echo CPPLib CMake Presets Demo
echo ==============================================

REM Check if VCPKG_ROOT is set
if "%VCPKG_ROOT%"=="" (
    echo Warning: VCPKG_ROOT environment variable is not set.
    echo Please set it to your vcpkg installation directory:
    echo   set VCPKG_ROOT=C:\path\to\vcpkg
    echo.
    echo Attempting to find vcpkg automatically...

    if exist "C:\vcpkg\scripts\buildsystems\vcpkg.cmake" (
        set "VCPKG_ROOT=C:\vcpkg"
        echo Found vcpkg at C:\vcpkg
    ) else if exist "vcpkg\scripts\buildsystems\vcpkg.cmake" (
        set "VCPKG_ROOT=vcpkg"
        echo Found vcpkg at .\vcpkg
    ) else (
        echo Error: Could not find vcpkg. Please install and set VCPKG_ROOT.
        pause
        exit /b 1
    )
    echo.
)

echo Using VCPKG_ROOT: %VCPKG_ROOT%
echo.

echo Available configure presets:
cmake --list-presets=configure
echo.

echo Available build presets:
cmake --list-presets=build
echo.

echo Available test presets:
cmake --list-presets=test
echo.

echo ==============================================
echo Quick Demo - Building with debug preset
echo ==============================================

echo Configuring with debug preset...
cmake --preset debug
if errorlevel 1 (
    echo Configuration failed!
    pause
    exit /b 1
)

echo.
echo Building with debug preset...
cmake --build --preset debug
if errorlevel 1 (
    echo Build failed!
    pause
    exit /b 1
)

echo.
echo ==============================================
echo Build completed successfully!
echo ==============================================
echo.
echo You can now run:
echo   build\debug\bin\cpplib_demo.exe
echo.
echo Other useful commands:
echo   cmake --preset shared-release    # Shared library build
echo   cmake --preset vs2022             # Visual Studio project
echo   cmake --workflow --preset full-build  # Complete workflow
echo.

pause
