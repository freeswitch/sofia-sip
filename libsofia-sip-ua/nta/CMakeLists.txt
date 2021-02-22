sofia_generate_tag_ref(LIST)

set(nta_sources
    nta.c nta_check.c nta_tag.c
    sl_utils_print.c sl_utils_log.c
    sl_read_payload.c
    ${CMAKE_CURRENT_BINARY_DIR}/nta_tag_ref.c
)

add_library(nta STATIC ${nta_sources})

if (NOT ENABLE_TESTS AND NOT ENABLE_NTA_TESTS)
    return()
endif (NOT ENABLE_TESTS AND NOT ENABLE_NTA_TESTS)

add_executable(portbind portbind.c)
target_link_libraries(portbind su)

add_executable(test_nta_api test_nta_api.c)
target_link_libraries(test_nta_api nta sip msg tport ${stun_module} ${http_module} sresolv url bnf su)
add_test(test_nta_api test_nta_api)

if (HAVE_CHECK)
    add_executable(test_nta test_nta.c)
    target_link_libraries(test_nta nta sip msg tport ${stun_module} ${http_module} sresolv url bnf su s2)
    add_test(test_nta test_nta)

    add_executable(check_nta check_nta.c check_nta_api.c check_nta_client.c)
    target_link_libraries(check_nta nta sip msg tport ${stun_module} ${http_module} sresolv url bnf su s2)
    add_test(check_nta check_nta)
endif (HAVE_CHECK)
