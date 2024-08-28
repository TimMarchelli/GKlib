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

# Find GKlib sources.
file(GLOB GKlib_sources ${CMAKE_CURRENT_SOURCE_DIR}/*.c)
file(GLOB GKlib_includes ${CMAKE_CURRENT_SOURCE_DIR}/*.h)
file(GLOB GKlib_win32_sources ${CMAKE_CURRENT_SOURCE_DIR}/win32/*.c)
file(GLOB GKlib_win32_includes ${CMAKE_CURRENT_SOURCE_DIR}/win32/*.h)

# other settings
include(GKlibSystem.cmake)

# compiler settings
include(cmake/ProjectCompilerSettings.cmake)

# the GKlib library
add_library(GKlib 
    ${GKlib_sources} 

    # Windows specific dependencies
    $<$<PLATFORM_ID:Windows>: ${GKlib_win32_sources}>
)

# set C standard to C99
set_target_properties(GKlib PROPERTIES C_STANDARD 99)

# set compiler settings
ProjectCompilerSettings(GKlib)

# set compiler options
target_compile_options(GKlib PRIVATE
    $<$<C_COMPILER_ID:GNU>:-fno-strict-aliasing>
    $<$<AND:$<PLATFORM_ID:Linux>,$<C_COMPILER_ID:GNU>>:-fPIC>
)

# add includes
target_include_directories(GKlib 
    PUBLIC 
        $<BUILD_INTERFACE:${GKlib_SOURCE_DIR}>
        $<INSTALL_INTERFACE:${INSTALL_INCLUDE_DIR}>

        # Windows specific includes
        $<$<PLATFORM_ID:Windows>: 
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/win32>
            $<INSTALL_INTERFACE:${INSTALL_INCLUDE_DIR}/win32>
        >
)

# add an alias for find
add_library(GKlib::GKlib ALIAS GKlib)

# add version information
set_target_properties(GKlib PROPERTIES 
    SOVERSION 0
    VERSION   0.0.1
)

# link to math library in linux
target_link_libraries(GKlib $<$<PLATFORM_ID:Linux>:m>)

# build tests
if(GKLIB_BUILD_TESTS)
    include(CTest)
    add_subdirectory(test)
endif()

# set a project config file to enable linking to libraries in the build directory
set(PROJECT_CONFIG_FILE "${CMAKE_BINARY_DIR}/GKlibConfig.cmake")
configure_package_config_file(GKlibConfig.cmake.in
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
install(FILES $<$<PLATFORM_ID:Windows>:${GKlib_win32_includes}> DESTINATION ${INSTALL_INCLUDE_DIR}/win32)

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
