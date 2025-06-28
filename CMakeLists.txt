cmake_minimum_required(VERSION 3.15)
project(sofia-sip C)

# parse project version
file(STRINGS ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}.spec SPEC_VERSION_LINE REGEX "^Version: +")
string(REGEX REPLACE ".+ +(.+)" "\\1" PROJECT_VERSION ${SPEC_VERSION_LINE})
set(PACKAGE_NAME    "${PROJECT_NAME}")
set(PACKAGE_VERSION "${PROJECT_VERSION}")
set(VERSION         "${PROJECT_VERSION}")
message(STATUS "${PROJECT_NAME}: ${PROJECT_VERSION}")

# project default make options
option(ENABLE_NTH         "HTTP-related modules nth and http (enabled)"        ON)
option(ENABLE_STUN        "enable stun module (enabled)"                       ON)
option(ENABLE_NTLM        "enable NTLM support (disabled)"                     OFF)
option(ENABLE_MEMLEAK_LOG "enable logging of possible memory leaks (disabled)" OFF)
option(ENABLE_TAG_CAST    "cast tag values with inlined functions (enabled)"   ON)
option(ENABLE_TESTS       "enable ctest framework"                             OFF)

SET(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
include(glib)
include(inline)
include(openssl)
include(pthread)
include(size_compat)
include(sofia)
include(FindUnixCommands)

# find pkg-config command
find_package(PkgConfig REQUIRED)

# Whether hava check library
pkg_check_modules(CHECK check>=0.9.4)
if (CHECK_FOUND)
    set(HAVE_CHECK 1)
endif (CHECK_FOUND)

# Check whether enable NTLM
if (ENABLE_NTLM)
    set(HAVE_NTLM       1)
    set(HAVE_SOFIA_NTLM 1)
endif (ENABLE_NTLM)

# Check whether enable memory leak log
if (ENABLE_MEMLEAK_LOG)
    set(HAVE_MEMLEAK_LOG 1)
endif (ENABLE_MEMLEAK_LOG)

# Check whether enable stun
if (ENABLE_STUN)
    set(HAVE_STUN       1)
    set(HAVE_SOFIA_STUN 1)
    if (NOT HAVE_OPENSSL)
        message(WARNING "** TLS support for STUN disabled as OpenSSL headers and/or libraries were not found **")
    endif (NOT HAVE_OPENSSL)
endif (ENABLE_STUN)

# Check whether enable nth
if (ENABLE_NTH)
    set(HAVE_NTH 1)
endif (ENABLE_NTH)

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/config.h.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/config.h
)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/s2check
    ${CMAKE_CURRENT_SOURCE_DIR}/tests
    ${CMAKE_CURRENT_BINARY_DIR}
)

# whether enable tests
if (ENABLE_TESTS)
    include(CTest)
endif (ENABLE_TESTS)
if (NOT ENABLE_TESTS AND ENABLE_MODULE_TEST)
    string(TOUPPER "enable_${ENABLE_MODULE_TEST}_TESTS" _var)
    set(${_var} 1)
    if (ENABLE_TPORT_TESTS)
        set(ENABLE_MSG_TESTS 1)
    endif ()
    include(CTest)
endif (NOT ENABLE_TESTS AND ENABLE_MODULE_TEST)

add_compile_options(-fPIC)
file(TOUCH ${CMAKE_CURRENT_BINARY_DIR}/dummy.c)
add_library(empty OBJECT ${CMAKE_CURRENT_BINARY_DIR}/dummy.c)

add_subdirectory(libsofia-sip-ua)
add_subdirectory(libsofia-sip-ua-glib)
add_subdirectory(s2check)
add_subdirectory(tests)
add_subdirectory(utils)
