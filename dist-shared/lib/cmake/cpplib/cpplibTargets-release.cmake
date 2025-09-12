#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "cpplib::cpplib" for configuration "Release"
set_property(TARGET cpplib::cpplib APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(cpplib::cpplib PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/cpplib.lib"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/cpplib.dll"
  )

list(APPEND _cmake_import_check_targets cpplib::cpplib )
list(APPEND _cmake_import_check_files_for_cpplib::cpplib "${_IMPORT_PREFIX}/lib/cpplib.lib" "${_IMPORT_PREFIX}/bin/cpplib.dll" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
