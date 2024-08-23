# Build program.
add_executable(strings strings.c)
add_executable(gksort gksort.c)
add_executable(fis fis.c)
add_executable(gkrw rw.c)
add_executable(gkgraph gkgraph.c)
add_executable(csrcnv csrcnv.c)
add_executable(grKx grKx.c)
add_executable(m2mnbrs m2mnbrs.c)
add_executable(cmpnbrs cmpnbrs.c)
add_executable(splatt2svd splatt2svd.c)

# contains inline assmble that doesn't work in MSVC
if(NOT MSVC)
    add_executable(gkuniq gkuniq.c)
endif()

# get targets
get_property(targets DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY BUILDSYSTEM_TARGETS)

foreach(target ${targets})
    target_link_libraries(${target} GKlib)

    # set compiler defines
    target_compile_definitions(${target} PRIVATE
        $<$<PLATFORM_ID:Windows>: WIN32 USE_GKREGEX >
        $<$<PLATFORM_ID:Linux>: LINUX _FILE_OFFSET_BITS=64 >
        $<$<PLATFORM_ID:CYGWIN>: CYGWIN >
        $<$<C_COMPILER_ID:MSVC>: MSC _CRT_SECURE_NO_DEPRECATE >
        $<$<AND:$<BOOL:${HAVE_THREADLOCALSTORAGE}>,$<C_COMPILER_ID:MSVC>>: "__thread=__declspec(thread)" >
        $<$<AND:$<NOT:$<BOOL:${HAVE_THREADLOCALSTORAGE}>>,$<C_COMPILER_ID:MSVC>>: __thread= >
    )

    # set warnings
    target_compile_options(${target} PRIVATE
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

endforeach()

# Install a subset of them
install(TARGETS csrcnv RUNTIME DESTINATION bin)
