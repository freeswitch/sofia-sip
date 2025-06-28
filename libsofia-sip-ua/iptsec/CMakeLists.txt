sofia_generate_tag_ref(PREFIX auth)

set(iptsec_sources
    auth_client.c auth_common.c auth_digest.c
    auth_module.c auth_tag.c
    auth_plugin.c auth_plugin_delayed.c
    auth_module_sip.c
    iptsec_debug.c
    ${CMAKE_CURRENT_BINARY_DIR}/auth_tag_ref.c
)

add_library(iptsec STATIC ${iptsec_sources})

if (NOT ENABLE_TESTS AND NOT ENABLE_AUTH_TESTS)
    return()
endif (NOT ENABLE_TESTS AND NOT ENABLE_AUTH_TESTS)

file(COPY testpasswd DESTINATION ${CMAKE_CURRENT_BINARY_DIR})

add_executable(test_auth_digest test_auth_digest.c)
target_link_libraries(test_auth_digest iptsec sip msg url bnf ipt su)
add_test(test_auth_digest test_auth_digest)
