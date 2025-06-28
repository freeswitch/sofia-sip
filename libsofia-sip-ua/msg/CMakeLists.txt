set(MSG_PARSER_AWK ${CMAKE_CURRENT_SOURCE_DIR}/msg_parser.awk)
set(SS_MIME_H      ${CMAKE_CURRENT_SOURCE_DIR}/sofia-sip/msg_mime.h)

include(awk)

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/sofia-sip)

## Generating sofia-sip/msg_protos.h
execute_process(
    COMMAND ${AWK} -f ${MSG_PARSER_AWK}
        module=msg NO_FIRST=1 NO_MIDDLE=1
        PR=${CMAKE_CURRENT_BINARY_DIR}/sofia-sip/msg_protos.h
        TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/sofia-sip/msg_protos.h.in
        ${SS_MIME_H}
)

## Generating sofia-sip/msg_mime_protos.h
execute_process(
    COMMAND ${AWK} -f ${MSG_PARSER_AWK}
        module=msg NO_FIRST=1 NO_LAST=1
        PR=${CMAKE_CURRENT_BINARY_DIR}/sofia-sip/msg_mime_protos.h
        TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/sofia-sip/msg_mime_protos.h.in
        ${SS_MIME_H}
)

## Generating msg_mime_table.c
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/msg_mime_table.c
    COMMAND ${AWK} -f ${MSG_PARSER_AWK}
        module=msg_multipart tprefix=msg prefix=mp MC_HASH_SIZE=127 MC_SHORT_SIZE=26
        PT=${CMAKE_CURRENT_BINARY_DIR}/msg_mime_table.c
        TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/msg_mime_table.c.in
        ${SS_MIME_H}
)

set(msg_sources
    msg.c msg_tag.c msg_inlined.c msg_mime.c
    msg_header_copy.c msg_header_make.c
    msg_parser.c msg_mclass.c msg_parser_util.c
    msg_basic.c msg_generic.c msg_date.c msg_auth.c
    ${CMAKE_CURRENT_BINARY_DIR}/msg_mime_table.c
)

add_library(msg STATIC ${msg_sources})

if (NOT ENABLE_TESTS AND NOT ENABLE_MSG_TESTS)
    return()
endif (NOT ENABLE_TESTS AND NOT ENABLE_MSG_TESTS)

set(TEST_CLASS_H ${CMAKE_CURRENT_SOURCE_DIR}/test_class.h)

## Generating test_protos.h
execute_process(
    COMMAND ${AWK} -f ${MSG_PARSER_AWK}
        module=msg_test NO_MIDDLE=1 NO_LAST=1
        PR=${CMAKE_CURRENT_BINARY_DIR}/test_protos.h
        TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/test_protos.h.in
        ${TEST_CLASS_H}
)

## Generating test_table.c
execute_process(
    COMMAND ${AWK} -f ${MSG_PARSER_AWK}
        module=msg_test prefix=msg
        MC_HASH_SIZE=127 multipart=msg_multipart
        PT=${CMAKE_CURRENT_BINARY_DIR}/test_table.c
        TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/test_table.c.in
        ${TEST_CLASS_H}
)

set(test_msg_sources
    test_class.c test_inlined.c
    ${CMAKE_CURRENT_BINARY_DIR}/test_table.c
)

add_library(test_msg STATIC ${test_msg_sources})
target_link_libraries(test_msg msg bnf url ipt su)

add_executable(test_msg_exec test_msg.c)
target_link_libraries(test_msg_exec test_msg)
add_test(test_msg_exec test_msg_exec)

add_executable(msg_name_hash msg_name_hash.c)
target_link_libraries(msg_name_hash test_msg)
