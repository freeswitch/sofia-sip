if (NOT ENABLE_TESTS)
    return()
endif (NOT ENABLE_TESTS)

include_directories(${INTERNAL_INCLUDE_DIRS})

set(nua_sources
    test_nua.h test_ops.c
    test_init.c
    test_nua_api.c test_nua_params.c
    test_register.c test_basic_call.c
    test_offer_answer.c
    test_call_reject.c test_cancel_bye.c
    test_call_hold.c test_session_timer.c
    test_refer.c test_100rel.c
    test_simple.c test_sip_events.c
    test_extension.c
)
set(proxy_sources test_proxy.c)
set(nat_sources test_nat.c test_nat_tags.c)

add_library(test_nua STATIC ${nua_sources} ${proxy_sources} ${nat_sources})

add_executable(test_nua_exec test_nua.c)
target_link_libraries(test_nua_exec sofia-sip-ua test_nua)
add_test(test_nua_exec test_nua_exec)

if (NOT HAVE_CHECK)
    return()
endif (NOT HAVE_CHECK)

add_executable(check_dlopen_sofia check_dlopen_sofia.c)
target_link_libraries(check_dlopen_sofia dl s2 sofia-sip-ua)
add_test(check_dlopen_sofia check_dlopen_sofia)

add_executable(check_sofia check_sofia.c suite_for_nua.c)
target_link_libraries(check_sofia sofia-sip-ua test_nua s2)
add_test(check_sofia check_sofia)
