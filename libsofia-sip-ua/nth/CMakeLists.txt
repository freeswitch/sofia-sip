sofia_generate_tag_ref()

set(nth_sources
    nth_client.c nth_server.c nth_tag.c
    ${CMAKE_CURRENT_BINARY_DIR}/nth_tag_ref.c
)

add_library(nth STATIC ${nth_sources})

if (NOT ENABLE_TESTS AND NOT ENABLE_NTH_TESTS)
    return()
endif (NOT ENABLE_TESTS AND NOT ENABLE_NTH_TESTS)

add_executable(http-client http-client.c)
target_link_libraries(http-client nth tport ${stun_module} ${http_module} msg sresolv url bnf sip iptsec ipt su)

add_executable(http-server http-server.c)
target_link_libraries(http-server nth tport ${stun_module} ${http_module} msg sresolv url bnf sip iptsec ipt su)

add_executable(test_nth test_nth.c)
target_link_libraries(test_nth nth tport ${stun_module} ${http_module} msg sresolv url bnf sip iptsec ipt su)
add_test(test_nth test_nth)
