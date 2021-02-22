sofia_generate_tag_ref()

set(tport_tls_sources  tport_type_tls.c tport_tls.c)
set(tport_stun_sources tport_stub_stun.c tport_type_stun.c)
set(tport_http_sources tport_type_connect.c tport_type_ws.c ws.c)
set(tport_sources
    tport.c tport_logging.c
    tport_stub_sigcomp.c
    tport_type_udp.c tport_type_tcp.c tport_type_sctp.c
    tport_tag.c
    ${CMAKE_CURRENT_BINARY_DIR}/tport_tag_ref.c
)
if (HAVE_TLS)
    set(tport_sources ${tport_sources} ${tport_tls_sources})
endif (HAVE_TLS)
if (HAVE_STUN)
    set(tport_sources ${tport_sources} ${tport_stun_sources})
endif (HAVE_STUN)
if (HAVE_NTH)
    set(tport_sources ${tport_sources} ${tport_http_sources})
endif (HAVE_NTH)

add_library(tport STATIC ${tport_sources})
target_include_directories(tport PRIVATE include)

if (NOT ENABLE_TESTS AND NOT ENABLE_TPORT_TESTS)
    return()
endif (NOT ENABLE_TESTS AND NOT ENABLE_TPORT_TESTS)

add_executable(test_tport test_tport.c)
file(COPY agent.pem cafile.pem DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
target_link_libraries(test_tport tport ${stun_module} ${http_module} sresolv test_msg)
add_test(test_tport test_tport)
