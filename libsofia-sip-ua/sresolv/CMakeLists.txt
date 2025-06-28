set(sresolv_sources
    sres.c sres_cache.c sres_blocking.c
    sresolv.c sres_sip.c
)

add_library(sresolv STATIC ${sresolv_sources})

if (NOT ENABLE_TESTS AND NOT ENABLE_SRES_TESTS)
    return()
endif (NOT ENABLE_TESTS AND NOT ENABLE_SRES_TESTS)

if (HAVE_CHECK)
    add_executable(check_sres_sip check_sres_sip.c)
    target_link_libraries(check_sres_sip sresolv sip msg tport ${stun_module} ${http_module} url bnf s2 su)
    add_test(check_sres_sip check_sres_sip)
endif (HAVE_CHECK)

add_executable(torture_sresolv torture_sresolv.c)
target_link_libraries(torture_sresolv sresolv url bnf su)
add_test(torture_sresolv torture_sresolv)

add_executable(test_sresolv test_sresolv.c)
target_link_libraries(test_sresolv sresolv url bnf su)
# TODO add run_test_sresolv into ctest
