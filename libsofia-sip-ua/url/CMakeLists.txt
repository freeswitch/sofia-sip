sofia_generate_tag_ref(DLLREF)

set(url_sources
    url.c url_tag.c
    ${CMAKE_CURRENT_BINARY_DIR}/url_tag_ref.c
)

add_library(url STATIC ${url_sources})

if (NOT ENABLE_TESTS AND NOT ENABLE_URL_TESTS)
    return()
endif (NOT ENABLE_TESTS AND NOT ENABLE_URL_TESTS)

add_executable(torture_url torture_url.c)
target_link_libraries(torture_url url bnf ipt su)
add_test(torture_url torture_url)
