macro(ProjectCompilerSettings tgt)

# set compiler defines
target_compile_definitions(${tgt} PRIVATE
    $<$<PLATFORM_ID:Windows>: WIN32 USE_GKREGEX >
    $<$<PLATFORM_ID:Linux>: LINUX _FILE_OFFSET_BITS=64 >
    $<$<PLATFORM_ID:CYGWIN>: CYGWIN >
    $<$<C_COMPILER_ID:MSVC>: MSC _CRT_SECURE_NO_DEPRECATE >
    $<$<AND:$<BOOL:${HAVE_THREADLOCALSTORAGE}>,$<C_COMPILER_ID:MSVC>>: "__thread=__declspec(thread)" >
    $<$<AND:$<NOT:$<BOOL:${HAVE_THREADLOCALSTORAGE}>>,$<C_COMPILER_ID:MSVC>>: __thread= >
)

# set warnings
target_compile_options(${tgt} PRIVATE
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
        -Wno-format 
        -Wno-format-invalid-specifier 
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

endmacro()