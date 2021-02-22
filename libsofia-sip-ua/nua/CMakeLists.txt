sofia_generate_tag_ref(LIST)

set(nua_sources
    nua.c nua_stack.h nua_common.c nua_stack.c
    nua_server.h nua_server.c
    nua_client.h nua_client.c
    nua_extension.c nua_types.h
    nua_dialog.c nua_dialog.h
    outbound.c outbound.h
    nua_params.c nua_params.h
    nua_register.c nua_registrar.c
    nua_session.c nua_options.c
    nua_message.c nua_publish.c nua_subnotref.c
    nua_notifier.c
    nua_event_server.c
    nua_tag.c
    ${CMAKE_CURRENT_BINARY_DIR}/nua_tag_ref.c
)

add_library(nua STATIC ${nua_sources})

if (NOT ENABLE_TESTS AND NOT ENABLE_NUA_TESTS)
    return()
endif (NOT ENABLE_TESTS AND NOT ENABLE_NUA_TESTS)

if (HAVE_CHECK)
    set(check_nua_sources
        check_nua.c check_nua.h
        check_session.c check_register.c
        check_etsi.c check_simple.c
    )
    add_executable(check_nua ${check_nua_sources})
    target_link_libraries(check_nua nua sip msg nta nea soa sdp tport sresolv ${stun_module} ${http_module} url bnf iptsec ipt s2 su)
    add_test(check_nua. check_nua)
endif (HAVE_CHECK)
