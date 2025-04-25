set(ipt_sources base64.c token64.c)

add_library(ipt STATIC ${ipt_sources})

if (NOT ENABLE_TESTS AND NOT ENABLE_IPT_TESTS)
    return()
endif (NOT ENABLE_TESTS AND NOT ENABLE_IPT_TESTS)

add_executable(torture_base64 torture_base64.c)
target_link_libraries(torture_base64 ipt)
add_test(torture_base64 torture_base64)
