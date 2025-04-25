configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/sofia-sip/sofia_features.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/sofia-sip/sofia_features.h
)

add_library(features STATIC features.c)
