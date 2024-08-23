cmake_minimum_required(VERSION 3.22)

project(GKlib C)

option(BUILD_SHARED_LIBS "Build shared libraries (.dll/.so) instead of static ones (.lib/.a)" OFF)
option(GKLIB_BUILD_TESTS "Build the GKlib tests." OFF)

# set a debug postfix
set(CMAKE_DEBUG_POSTFIX "d")

# default install location vars and configuration build tool
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# modify install targets
set(INSTALL_RUNTIME_DIR ${CMAKE_INSTALL_BINDIR})
set(INSTALL_CONFIG_DIR  ${CMAKE_INSTALL_LIBDIR}/cmake/GKlib)
set(INSTALL_LIBRARY_DIR ${CMAKE_INSTALL_LIBDIR})
set(INSTALL_INCLUDE_DIR ${CMAKE_INSTALL_INCLUDEDIR}/GKlib)

get_filename_component(abs "." ABSOLUTE)
set(GKLIB_PATH ${abs})
unset(abs)
include(GKlibSystem.cmake)

include_directories(".")
if(MSVC)
    include_directories("win32")
    file(GLOB win32_sources RELATIVE "win32" "*.c")
else(MSVC)
    set(win32_sources, "")
endif(MSVC)

# the GKlib library
add_library(GKlib ${GKlib_sources} ${win32_sources} ${GKlib_includes})

# set C standard to C99
set_target_properties(GKlib PROPERTIES C_STANDARD 99)

# set compiler defines
target_compile_definitions(GKlib PRIVATE
    $<$<PLATFORM_ID:Windows>: WIN32 USE_GKREGEX >
    $<$<PLATFORM_ID:Linux>: LINUX _FILE_OFFSET_BITS=64 >
    $<$<PLATFORM_ID:CYGWIN>: CYGWIN >
    $<$<C_COMPILER_ID:MSVC>: MSC _CRT_SECURE_NO_DEPRECATE >
    $<$<AND:$<BOOL:${HAVE_THREADLOCALSTORAGE}>,$<C_COMPILER_ID:MSVC>>: "__thread=__declspec(thread)" >
    $<$<AND:$<NOT:$<BOOL:${HAVE_THREADLOCALSTORAGE}>>,$<C_COMPILER_ID:MSVC>>: __thread= >
)

# set compiler options
target_compile_options(GKlib PRIVATE
    $<$<C_COMPILER_ID:GNU>:-fno-strict-aliasing>
    $<$<AND:$<PLATFORM_ID:Linux>,$<C_COMPILER_ID:GNU>>:-fPIC>
)

# set warnings
target_compile_options(GKlib PRIVATE
    # GNU options
    $<$<C_COMPILER_ID:GNU>: -Werror
        -Wall 
        -pedantic 
        -Wno-unused-function 
        -Wno-unused-but-set-variable 
        -Wno-unused-variable 
        -Wno-unknown-pragmas 
        -Wno-unused-label 
        -Wno-int-to-pointer-cast
        -Wno-pointer-to-int-cast
        -Wno-maybe-uninitialized >

    # Clang options
    $<$<C_COMPILER_ID:Clang>: -Wno-deprecated-declarations 
        -Wno-implicit-function-declaration 
        -Wno-format -Wno-format-invalid-specifier 
        -Wno-format-extra-args 
        -Wno-format-invalid-specifier 
        -Wno-deprecated-non-prototype 
        -Wno-int-to-void-pointer-cast 
        -Wno-void-pointer-to-int-cast 
        -Wno-unused-variable 
        -Wno-unused-function 
        -Wno-unused-but-set-variable >

    # MSVC options
    $<$<C_COMPILER_ID:MSVC>: /wd4005 /wd4311 /wd4312 >
)

# add includes
target_include_directories(GKlib 
    PUBLIC 
        $<BUILD_INTERFACE:${GKlib_SOURCE_DIR}>
        $<INSTALL_INTERFACE:${INSTALL_INCLUDEDIR}>
)

if(MSVC)
    target_include_directories(GKlib 
        PUBLIC 
            $<BUILD_INTERFACE:${GKlib_SOURCE_DIR}/win32>
            $<INSTALL_INTERFACE:${INSTALL_INCLUDEDIR}/win32>
)
endif()

# add an alias for find
add_library(GKlib::GKlib ALIAS GKlib)

# add version information
set_target_properties(GKlib PROPERTIES 
    SOVERSION 0
    VERSION   0.0.1
)

if(UNIX)
    target_link_libraries(GKlib m)
endif(UNIX)

if(GKLIB_BUILD_TESTS)
    include_directories("test")
    add_subdirectory("test")
endif()

# set a project config file to enable linking to libraries in the build directory
set(PROJECT_CONFIG_FILE "${CMAKE_BINARY_DIR}/GKlib-config.cmake")
configure_package_config_file(GKlib-config.cmake.in
  ${PROJECT_CONFIG_FILE}
  INSTALL_DESTINATION ${INSTALL_CONFIG_DIR}
)

# install library
install(TARGETS GKlib
    EXPORT GKlib-targets
    RUNTIME DESTINATION ${INSTALL_RUNTIME_DIR}
    LIBRARY DESTINATION ${INSTALL_LIBRARY_DIR}
    ARCHIVE DESTINATION ${INSTALL_LIBRARY_DIR}
)

# install includes
install(FILES ${GKlib_includes} DESTINATION ${INSTALL_INCLUDE_DIR})

# install windows includes
if(MSVC)
    install(FILES "win32/adapt.h" DESTINATION ${INSTALL_INCLUDE_DIR}/win32)
endif()

install(FILES
    ${PROJECT_CONFIG_FILE}
    DESTINATION ${INSTALL_CONFIG_DIR}
)

# install config
install(EXPORT GKlib-targets 
    FILE GKlib-targets.cmake 
    NAMESPACE GKlib::
    DESTINATION ${INSTALL_CONFIG_DIR}
)
