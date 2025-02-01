if (NOT HAVE_CHECK)
    return()
endif (NOT HAVE_CHECK)

include_directories(${INTERNAL_INCLUDE_DIRS})

set(s2_sources
    s2check.h s2tcase.c
    s2base.h s2base.c
    s2sip.c s2sip.h
    s2_localinfo.h s2_localinfo.c
    s2dns.h s2dns.c
    s2util.h s2time.c
)

add_library(s2 STATIC ${s2_sources})
target_link_libraries(s2 ${CHECK_LIBRARIES})
target_include_directories(s2 PRIVATE ${CHECK_INCLUDEDIR})
