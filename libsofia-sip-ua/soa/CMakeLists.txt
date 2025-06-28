sofia_generate_tag_ref(LIST)

set(soa_sources
    soa.c soa_static.c soa_tag.c
    ${CMAKE_CURRENT_BINARY_DIR}/soa_tag_ref.c
)

add_library(soa STATIC ${soa_sources})

if (NOT ENABLE_TESTS AND NOT ENABLE_SOA_TESTS)
    return()
endif (NOT ENABLE_TESTS AND NOT ENABLE_SOA_TESTS)

if (HAVE_CHECK)
    add_executable(test_soa test_soa.c)
    target_link_libraries(test_soa soa ${stun_module} ${http_module} sdp bnf sip msg url tport sresolv s2 su)
    add_test(test_soa test_soa)
endif (HAVE_CHECK)
