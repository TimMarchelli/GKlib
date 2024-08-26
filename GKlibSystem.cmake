# Helper modules.
include(CheckFunctionExists)
include(CheckIncludeFile)

# Setup options.
option(GDB "enable use of GDB" OFF)
option(ASSERT "turn asserts on" OFF)
option(ASSERT2 "additional assertions" OFF)
option(DEBUG "add debugging support" OFF)
option(GPROF "add gprof support" OFF)
option(VALGRIND "add valgrind support" OFF)
option(OPENMP "enable OpenMP support" OFF)
option(PCRE "enable PCRE support" OFF)
option(GKREGEX "enable GKREGEX support" OFF)
option(GKRAND "enable GKRAND support" OFF)
option(NO_X86 "enable NO_X86 support" OFF)


# Add compiler flags.
if(MSVC)
    set(GKlib_COPTIONS "-DWIN32 -DMSC -D_CRT_SECURE_NO_DEPRECATE -DUSE_GKREGEX")
elseif(MINGW)
    set(GKlib_COPTS "-DUSE_GKREGEX")
else()
    set(GKlib_COPTIONS "-DLINUX -D_FILE_OFFSET_BITS=64")
endif()

if(CYGWIN)
    set(GKlib_COPTIONS "${GKlib_COPTIONS} -DCYGWIN")
endif()

if(CMAKE_COMPILER_IS_GNUCC)
    # GCC opts.
    set(GKlib_COPTIONS "${GKlib_COPTIONS} -fno-strict-aliasing")
    
    if(VALGRIND)
        set(GKlib_COPTIONS "${GK_COPTIONS} -march=x86-64 -mtune=generic")
    else()
        # -march=native is not a valid flag on PPC:
        if(CMAKE_SYSTEM_PROCESSOR MATCHES "power|ppc|powerpc|ppc64|powerpc64" OR (APPLE AND CMAKE_OSX_ARCHITECTURES MATCHES "ppc|ppc64"))
            set(GKlib_COPTIONS "${GKlib_COPTIONS} -mtune=native")
        else()
            set(GKlib_COPTIONS "${GKlib_COPTIONS} -march=native")
        endif()
    endif()

    if(NOT MINGW)
        set(GKlib_COPTIONS "${GKlib_COPTIONS} -fPIC")
    endif()
    
    # GCC warnings.
    set(GKlib_COPTIONS "${GKlib_COPTIONS} -Werror -Wall -pedantic -Wno-unused-function -Wno-unused-but-set-variable -Wno-unused-variable -Wno-unknown-pragmas -Wno-unused-label")

elseif(${CMAKE_C_COMPILER_ID} MATCHES "Sun")
    # Sun insists on -xc99.
    set(GKlib_COPTIONS "${GKlib_COPTIONS} -xc99")
endif()

# Intel compiler
if(${CMAKE_C_COMPILER_ID} STREQUAL "Intel")
    set(GKlib_COPTIONS "${GKlib_COPTIONS} -xHost")
endif()

# Find OpenMP if it is requested.
if(OPENMP)
    include(FindOpenMP)
    if(OPENMP_FOUND)
        set(GKlib_COPTIONS "${GKlib_COPTIONS} -D__OPENMP__ ${OpenMP_C_FLAGS}")
    else()
        message(WARNING "OpenMP was requested but support was not found")
    endif()
endif()

# Set the CPU type 
if(NO_X86)
    set(GKlib_COPTIONS "${GKlib_COPTIONS} -DNO_X86=${NO_X86}")
endif()

if(GPROF)
    set(GKlib_COPTS "-pg")
endif()

if(NOT ASSERT)
    set(GKlib_COPTIONS "${GKlib_COPTIONS} -DNDEBUG")
endif()

if(NOT ASSERT2)
    set(GKlib_COPTIONS "${GKlib_COPTIONS} -DNDEBUG2")
endif()


# Add various options
if(PCRE)
    set(GKlib_COPTIONS "${GKlib_COPTIONS} -D__WITHPCRE__")
endif()

if(GKREGEX)
    set(GKlib_COPTIONS "${GKlib_COPTIONS} -DUSE_GKREGEX")
endif()

if(GKRAND)
    set(GKlib_COPTIONS "${GKlib_COPTIONS} -DUSE_GKRAND")
endif()


# Check for features.
check_include_file(execinfo.h HAVE_EXECINFO_H)
if(HAVE_EXECINFO_H)
    set(GKlib_COPTIONS "${GKlib_COPTIONS} -DHAVE_EXECINFO_H")
endif()

check_function_exists(getline HAVE_GETLINE)
if(HAVE_GETLINE)
    set(GKlib_COPTIONS "${GKlib_COPTIONS} -DHAVE_GETLINE")
endif()


# Custom check for TLS.
if(MSVC)
    # This if checks if that value is cached or not.
    if("${HAVE_THREADLOCALSTORAGE}" MATCHES "^${HAVE_THREADLOCALSTORAGE}$")
        try_compile(HAVE_THREADLOCALSTORAGE
        ${CMAKE_CURRENT_BINARY_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}/conf/check_thread_storage.c
        COMPILE_DEFINITIONS "-D__thread=__declspec(thread)")

        if(HAVE_THREADLOCALSTORAGE)
            message(STATUS "checking for thread-local storage - found")
        else()
            message(STATUS "checking for thread-local storage - not found")
        endif()

    endif()
endif()

# Finally set the official C flags.
set(GKLIB_C_FLAGS "${GKlib_COPTIONS} ${GKlib_COPTS}")
