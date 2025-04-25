include_directories(${INTERNAL_INCLUDE_DIRS})

add_library(su-glib STATIC su_source.c)
target_link_libraries(su-glib ${GLIB_LIBRARIES})

if (NOT ENABLE_TESTS AND NOT ENABLE_GLIB_TESTS)
    return()
endif (NOT ENABLE_TESTS AND NOT ENABLE_GLIB_TESTS)

add_executable(su_source_test su_source_test.c)
target_link_libraries(su_source_test su-glib sofia-sip-ua)
add_test(su_source_test su_source_test)

add_executable(torture_su_glib_timer torture_su_glib_timer.c)
target_link_libraries(torture_su_glib_timer su-glib sofia-sip-ua)
add_test(torture_su_glib_timer torture_su_glib_timer)
