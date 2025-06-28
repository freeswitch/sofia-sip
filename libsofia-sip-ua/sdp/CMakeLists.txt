sofia_generate_tag_ref()

set(sdp_sources
    sdp.c sdp_parse.c sdp_print.c sdp_tag.c
    ${CMAKE_CURRENT_BINARY_DIR}/sdp_tag_ref.c
)

add_library(sdp STATIC ${sdp_sources})

if (NOT ENABLE_TESTS AND NOT ENABLE_SDP_TESTS)
    return()
endif (NOT ENABLE_TESTS AND NOT ENABLE_SDP_TESTS)

add_executable(torture_sdp torture_sdp.c)
target_link_libraries(torture_sdp sdp su)
add_test(torture_sdp torture_sdp)

add_executable(test_sdp test_sdp.c)
target_link_libraries(test_sdp sdp su)
foreach (loop_var RANGE 1 10)
    add_test(run_test_sdp_${loop_var} test_sdp ${CMAKE_CURRENT_SOURCE_DIR}/tests/message-${loop_var}.sdp)
endforeach (loop_var)
set_tests_properties(run_test_sdp_1 run_test_sdp_6 PROPERTIES WILL_FAIL TRUE)
