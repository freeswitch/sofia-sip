sofia_generate_tag_ref(LIST)

set(stun_sources
    stun.c stun_common.c stun_dns.c stun_mini.c stun_tag.c
    ${CMAKE_CURRENT_BINARY_DIR}/stun_tag_ref.c
)

add_library(stun STATIC ${stun_sources})

add_executable(stunc stunc.c)
target_link_libraries(stunc stun sresolv url bnf su)

if (NOT ENABLE_TESTS AND NOT ENABLE_STUN_TESTS)
    return()
endif (NOT ENABLE_TESTS AND NOT ENABLE_STUN_TESTS)

add_executable(lookup_stun_server lookup_stun_server.c)
target_link_libraries(lookup_stun_server stun sresolv url bnf su)
