sofia_generate_tag_ref()

set(nea_sources
    nea.c nea_event.c
    nea_server.c nea_debug.h nea_debug.c
    nea_tag.c
    ${CMAKE_CURRENT_BINARY_DIR}/nea_tag_ref.c
)

add_library(nea STATIC ${nea_sources})
