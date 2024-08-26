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
add_executable(gkuniq gkuniq.c)

# get targets
get_property(targets DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY BUILDSYSTEM_TARGETS)

# link GKlib and set compiler settings
foreach(target ${targets})
    target_link_libraries(${target} GKlib)

    # compiler settings
    ProjectCompilerSettings(${target})
endforeach()

# Install a subset of them
install(TARGETS csrcnv RUNTIME DESTINATION bin)

# add some tests
add_test(NAME strings COMMAND strings)
add_test(NAME gksort COMMAND gksort)
add_test(NAME gkuniq COMMAND gkuniq 1000 5)