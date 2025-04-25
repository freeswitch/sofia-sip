set(MSG_PARSER_AWK ${CMAKE_CURRENT_SOURCE_DIR}/../msg/msg_parser.awk)
set(SS_SIP_H       ${CMAKE_CURRENT_SOURCE_DIR}/sofia-sip/sip.h)
set(SS_SIP_H_EXTRA ${CMAKE_CURRENT_SOURCE_DIR}/sip_extra_headers.txt)

include(awk)

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/sofia-sip)

## Generating sofia-sip/sip_hclasses.h
execute_process(
    COMMAND ${AWK} -f ${MSG_PARSER_AWK} module=sip
        PR=${CMAKE_CURRENT_BINARY_DIR}/sofia-sip/sip_hclasses.h
        TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/sofia-sip/sip_hclasses.h.in
        ${SS_SIP_H}
)

## Generating sofia-sip/sip_protos.h
execute_process(
    COMMAND ${AWK} -f ${MSG_PARSER_AWK} module=sip
        PR=${CMAKE_CURRENT_BINARY_DIR}/sofia-sip/sip_protos.h
        TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/sofia-sip/sip_protos.h.in
        ${SS_SIP_H}
)

## Generating sofia-sip/sip_tag.h
execute_process(
    COMMAND ${AWK} -f ${MSG_PARSER_AWK} module=sip
        PR=${CMAKE_CURRENT_BINARY_DIR}/sofia-sip/sip_tag.h
        TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/sofia-sip/sip_tag.h.in
        ${SS_SIP_H}
)

## Generating sofia-sip/sip_extra.h
execute_process(
    COMMAND ${AWK} -f ${MSG_PARSER_AWK} module=sip
        NO_FIRST=1 NO_LAST=1
        PACKAGE_NAME="${PACKAGE_NAME}"
        PACKAGE_VERSION="${PACKAGE_VERSION}"
        PR=${CMAKE_CURRENT_BINARY_DIR}/sofia-sip/sip_extra.h
        TEMPLATE1=${CMAKE_CURRENT_SOURCE_DIR}/sofia-sip/sip_hclasses.h.in
        TEMPLATE2=${CMAKE_CURRENT_SOURCE_DIR}/sofia-sip/sip_protos.h.in
        TEMPLATE3=${CMAKE_CURRENT_SOURCE_DIR}/sofia-sip/sip_tag.h.in
        TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/sofia-sip/sip_extra.h.in
        ${SS_SIP_H_EXTRA}
)

## Generating sip_tag.c
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/sip_tag.c
    COMMAND ${AWK} -f ${MSG_PARSER_AWK} module=sip
        PR=${CMAKE_CURRENT_BINARY_DIR}/sip_tag.c
        TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/sip_tag.c.in
        ${SS_SIP_H} ${SS_SIP_H_EXTRA}
)

## Generating sip_parser_table.c
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/sip_parser_table.c
    COMMAND ${AWK} -f ${MSG_PARSER_AWK} module=sip
        MC_HASH_SIZE=127 MC_SHORT_SIZE=26
        FLAGFILE=${CMAKE_CURRENT_SOURCE_DIR}/sip_bad_mask
        PT=${CMAKE_CURRENT_BINARY_DIR}/sip_parser_table.c
        TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/sip_parser_table.c.in
        ${SS_SIP_H} ${SS_SIP_H_EXTRA}
)

## Generating sip_tag_ref.c
sofia_generate_tag_ref()

set(sip_sources
    sip_parser.c sip_header.c sip_util.c sip_pref_util.c
    sip_basic.c sip_extra.c sip_feature.c sip_mime.c
    sip_security.c sip_event.c sip_prack.c
    sip_refer.c sip_session.c
    sip_caller_prefs.c sip_reason.c
    sip_status.c sip_time.c
    sip_tag_class.c sip_inlined.c
    ${CMAKE_CURRENT_BINARY_DIR}/sip_tag.c
    ${CMAKE_CURRENT_BINARY_DIR}/sip_tag_ref.c
    ${CMAKE_CURRENT_BINARY_DIR}/sip_parser_table.c
)

add_library(sip STATIC ${sip_sources})

if (NOT ENABLE_TESTS AND NOT ENABLE_SIP_TESTS)
    return()
endif (NOT ENABLE_TESTS AND NOT ENABLE_SIP_TESTS)

add_executable(torture_sip torture_sip.c)
target_link_libraries(torture_sip sip msg bnf url ipt su)
add_test(torture_sip torture_sip)

add_executable(test_date test_date.c)
target_link_libraries(test_date sip msg bnf url ipt su)
add_test(test_date test_date "Sun, 18 Mar 2001 23:01:00 GMT")

add_executable(test_sip_msg test_sip_msg.c)
target_link_libraries(test_sip_msg sip msg bnf url ipt su)

add_executable(validator validator.c)
target_link_libraries(validator sip msg bnf url ipt su)

set(test_flag "-t")

# These are messages that the parser should pass
set(good_messages
    -t test1.txt test2.txt test3.txt test4.txt
    -u test5.txt -t test6.txt test7.txt -u test8.txt -t test9.txt
    test14.txt test20.txt test23.txt test24.txt test31.txt
    own1.txt own2.txt own3.txt own4.txt own5.txt own6.txt
)
# These are ugly messages that parser should pass
set(ugly_messages
    -t test25.txt -u test27.txt test28.txt -t test30.txt
    -u test32.txt test34.txt -t test36.txt -u test37.txt
    test38.txt test39.txt test41.txt test42.txt
)
# These are messages that the parser should fail
set(bad_messages
    test10.txt test11.txt test12.txt test13.txt test15.txt
    test16.txt test17.txt test18.txt test19.txt
    test21.txt test22.txt
    test26.txt test29.txt test33.txt
    test35.txt
    test40.txt
)
foreach (_txt ${good_messages} ${ugly_messages})
    if (_txt MATCHES "^\\-")
        set(test_flag ${_txt})
        continue()
    endif ()
    add_test(
        NAME test_sip_msg_${_txt}
        COMMAND ${BASH} -c "$<TARGET_FILE:test_sip_msg> ${test_flag} < ${CMAKE_CURRENT_SOURCE_DIR}/tests/${_txt}"
    )
endforeach (_txt)
foreach (_txt ${bad_messages})
    add_test(
        NAME test_sip_msg_${_txt}
        COMMAND ${BASH} -c "$<TARGET_FILE:test_sip_msg> ${test_flag} < ${CMAKE_CURRENT_SOURCE_DIR}/tests/${_txt}"
    )
    set_tests_properties(test_sip_msg_${_txt} PROPERTIES WILL_FAIL TRUE)
endforeach (_txt)
