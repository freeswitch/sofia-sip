########## generator su_configure.h ##########
if (HAVE_STDINT_H)
    set(SU_HAVE_STDINT 1)
endif (HAVE_STDINT_H)
if (HAVE_INTTYPES_H)
    set(SU_HAVE_INTTYPES 1)
endif (HAVE_INTTYPES_H)
if (HAVE_SYS_TYPES_H)
    set(SU_HAVE_SYS_TYPES 1)
endif (HAVE_SYS_TYPES_H)
if (HAVE_PTHREAD_H)
    set(SU_HAVE_PTHREADS 1)
endif (HAVE_PTHREAD_H)
if (HAVE_SOCKET)
    set(SU_HAVE_BSDSOCK 1)
endif (HAVE_SOCKET)
if (HAVE_SA_LEN)
    set(HAVE_SOCKADDR_SA_LEN 1)
endif (HAVE_SA_LEN)

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/sofia-sip/su_configure.h.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/sofia-sip/su_configure.h
)

set(su_sources
    su.c su_errno.c su_addrinfo.c
    su_alloc.c su_alloc_lock.c su_strdup.c su_sprintf.c
    su_strlst.c su_vector.c
    su_time.c su_time0.c
    su_wait.c su_root.c su_timer.c
    su_port.c su_port.h
    su_base_port.c su_pthread_port.c su_socket_port.c
    su_poll_port.c su_epoll_port.c su_select_port.c su_kqueue_port.c
    su_devpoll_port.c su_localinfo.c su_os_nw.c
    su_taglist.c su_tag.c su_tag_io.c
    su_log.c su_global_log.c su_default_log.c su_module_debug.h
    su_md5.c su_uniqueid.c su_bm.c smoothsort.c su_string.c string0.c
)
set(su_extra_sources
    memmem.c strtoull.c
    memspn.c memcspn.c memccpy.c
    inet_ntop.c inet_pton.c poll.c getopt.c
)
foreach (_su_extra_src ${su_extra_sources})
    string(REGEX REPLACE ".c$" "" _src_filename ${_su_extra_src})
    string(TOUPPER "have_${_src_filename}" _var)
    if (NOT ${_var})
        set(su_sources ${su_sources} ${_su_extra_src})
    endif (NOT ${_var})
endforeach (_su_extra_src)

add_library(su STATIC ${su_sources})

add_executable(addrinfo addrinfo.c)
target_link_libraries(addrinfo su)

add_executable(localinfo localinfo.c)
target_link_libraries(localinfo su)

if (NOT ENABLE_TESTS AND NOT ENABLE_SU_TESTS)
    return()
endif (NOT ENABLE_TESTS AND NOT ENABLE_SU_TESTS)

set(su_testable_binaries
    torture_su torture_su_port
    torture_su_alloc torture_su_time torture_su_tag
    test_htable test_htable2 torture_rbtree torture_heap
    test_memmem torture_su_bm torture_su_root torture_su_timer
)
set(su_test_binaries
    ${su_testable_binaries}
    test_su su_proxy test_poll
)

foreach (bin ${su_test_binaries})
    add_executable(${bin} ${bin}.c)
    target_link_libraries(${bin} su)
endforeach (bin)
foreach (bin ${su_testable_binaries})
    add_test(${bin} ${bin})
endforeach (bin)
add_test(run_addrinfo addrinfo -n echo 127.0.0.1)
add_test(run_localinfo localinfo -n)
foreach (SU_PORT select kqueue devpoll epoll poll)
    string(TOUPPER "have_${SU_PORT}" _var)
    if (NOT ${_var})
        continue()
    endif (NOT ${_var})
    add_test(test_su_${SU_PORT} test_su)
    add_test(test_su_${SU_PORT}_s test_su -s)
    set_tests_properties(test_su_${SU_PORT} test_su_${SU_PORT}_s PROPERTIES ENVIRONMENT "SU_PORT=${SU_PORT}")
endforeach (SU_PORT)
