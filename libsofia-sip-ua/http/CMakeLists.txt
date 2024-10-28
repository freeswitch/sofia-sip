set(MSG_PARSER_AWK ${CMAKE_CURRENT_SOURCE_DIR}/../msg/msg_parser.awk)
set(SS_HTTP_H      ${CMAKE_CURRENT_SOURCE_DIR}/sofia-sip/http.h)

include(awk)

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/sofia-sip)

## Generating sofia-sip/http_protos.h
execute_process(
    COMMAND ${AWK} -f ${MSG_PARSER_AWK} module=http
        PR=${CMAKE_CURRENT_BINARY_DIR}/sofia-sip/http_protos.h
        TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/sofia-sip/http_protos.h.in
        ${SS_HTTP_H}
)

## Generating sofia-sip/http_tag.h
execute_process(
    COMMAND ${AWK} -f ${MSG_PARSER_AWK} module=http
        PR=${CMAKE_CURRENT_BINARY_DIR}/sofia-sip/http_tag.h
        TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/sofia-sip/http_tag.h.in
        ${SS_HTTP_H}
)

## Generating http_tag.c
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/http_tag.c
    COMMAND ${AWK} -f ${MSG_PARSER_AWK} module=http
        PR=${CMAKE_CURRENT_BINARY_DIR}/http_tag.c
        TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/http_tag.c.in
        ${SS_HTTP_H}
)

## Generating http_parser_table.c
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/http_parser_table.c
    COMMAND ${AWK} -f ${MSG_PARSER_AWK} module=http
        MC_HASH_SIZE=127
        PT=${CMAKE_CURRENT_BINARY_DIR}/http_parser_table.c
        TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/http_parser_table.c.in
        ${SS_HTTP_H}
)

## Generating sip_tag_ref.c
sofia_generate_tag_ref(DLLREF)

set(http_sources
    http_parser.c http_header.c
    http_basic.c http_extra.c http_inlined.c
    http_status.c http_tag_class.c
    ${CMAKE_CURRENT_BINARY_DIR}/http_tag.c
    ${CMAKE_CURRENT_BINARY_DIR}/http_tag_ref.c
    ${CMAKE_CURRENT_BINARY_DIR}/http_parser_table.c
)

add_library(http STATIC ${http_sources})

if (NOT ENABLE_TESTS AND NOT ENABLE_HTTP_TESTS)
    return()
endif (NOT ENABLE_TESTS AND NOT ENABLE_HTTP_TESTS)

add_executable(test_http test_http.c)
target_link_libraries(test_http http bnf msg url su)
add_test(test_http test_http)
