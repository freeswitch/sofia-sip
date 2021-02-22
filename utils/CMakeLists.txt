include_directories(${INTERNAL_INCLUDE_DIRS})

add_executable(sip-date sip-date.c)
target_link_libraries(sip-date sofia-sip-ua)

add_executable(sip-dig sip-dig.c)
target_link_libraries(sip-dig sofia-sip-ua)

add_executable(sip-options sip-options.c)
target_link_libraries(sip-options sofia-sip-ua)
