if (NOT HAVE_GLIB)
    return()
endif (NOT HAVE_GLIB)

set(sofia_glib_modules su-glib)

foreach (_dir ${sofia_glib_modules})
    set(${_dir}_include_dirs ${CMAKE_CURRENT_SOURCE_DIR}/${_dir} ${CMAKE_CURRENT_BINARY_DIR}/${_dir})
    list(APPEND INTERNAL_INCLUDE_DIRS ${${_dir}_include_dirs})
    include_directories(${${_dir}_include_dirs})
endforeach (_dir)
set(INTERNAL_INCLUDE_DIRS ${INTERNAL_INCLUDE_DIRS} PARENT_SCOPE)
foreach (_dir ${sofia_glib_modules})
    add_subdirectory(${_dir})
endforeach (_dir)

add_library(sofia-sip-ua-glib SHARED)
target_link_libraries(sofia-sip-ua-glib empty)
target_link_libraries(sofia-sip-ua-glib -Wl,--whole-archive ${sofia_glib_modules} -Wl,--no-whole-archive)
