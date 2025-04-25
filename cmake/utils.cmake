if (__UTILS_INCLUDED)
    return()
endif (__UTILS_INCLUDED)
set(__UTILS_INCLUDED TRUE)

include(awk)
include(CMakeParseArguments)
include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CheckFunctionExists)
include(CheckIncludeFile)
include(CheckLibraryExists)
include(CheckStructHasMember)
include(CheckSymbolExists)

macro(sofia_include_file header)
    string(REGEX REPLACE "[^a-zA-Z0-9]" "_" _file ${header})
    string(TOUPPER "have_${_file}" _var)
    check_include_file(${header} ${_var})
    if (${_var})
        set(SU_${_var} 1)
        if (NOT "${header}" IN_LIST CMAKE_EXTRA_INCLUDE_FILES)
            list(APPEND CMAKE_EXTRA_INCLUDE_FILES ${header})
        endif ()
    endif (${_var})
endmacro(sofia_include_file)

macro(sofia_symbol_exists symbol)
    set(_var "${ARGN}")
    if ("${_var}" STREQUAL "")
        string(REGEX REPLACE "[^a-zA-Z0-9]" "_" _symbol ${symbol})
        string(TOUPPER "have_${_symbol}" _var)
    endif ()

    check_symbol_exists(${symbol} "${CMAKE_EXTRA_INCLUDE_FILES}" _symbol_${_var})
    if (${_symbol_${_var}})
        set(${_var} ${_symbol_${_var}})
    else ()
        check_function_exists(${symbol} ${_var})
    endif ()
    if (${_var})
        set(SU_${_var} 1)
    endif (${_var})
endmacro(sofia_symbol_exists)

macro(sofia_struct_has_member struct member var)
    check_struct_has_member(${struct} ${member} "${CMAKE_EXTRA_INCLUDE_FILES}" ${var})
    if (${var})
        set(SU_${var} 1)
    endif (${var})
endmacro(sofia_struct_has_member)

macro(sofia_type_exists type var)
    set(_sofia_c_source)
    foreach (_c_header ${CMAKE_EXTRA_INCLUDE_FILES})
        SET(_sofia_c_source "${_sofia_c_source}
		#include <${_c_header}>")
    endforeach (_c_header)
    set(_sofia_c_source "${_sofia_c_source}
		int main() {
			${type} var_exists;
			(void)var_exists;
			return 0;
		}
	")
    check_c_source_compiles("${_sofia_c_source}" ${var})
    if (${var})
        set(SU_${var} 1)
    endif (${var})
endmacro(sofia_type_exists)

macro(sofia_source_runs source var)
    set(_sofia_c_source)
    foreach (_c_header ${CMAKE_EXTRA_INCLUDE_FILES})
        SET(_sofia_c_source "${_sofia_c_source}
		#include <${_c_header}>")
    endforeach (_c_header)
    set(_sofia_c_source "${_sofia_c_source}
		${source}
	")
    check_c_source_runs("${_sofia_c_source}" "${var}")
    if (${var})
        set(SU_${var} 1)
    endif (${var})
endmacro(sofia_source_runs)

macro(sofia_library_exists library function)
    set(_var "${ARGN}")
    if ("${_var}" STREQUAL "")
        string(TOUPPER "have_${library}" _var)
    endif ()
    find_library(_${library}_location NAMES ${library})
    check_library_exists("${library}" "${function}" "${_${library}_location}" "${_var}")
    if (${_var})
        set(SU_${_var} 1)
    endif (${_var})
endmacro(sofia_library_exists)

## Generating xxx_tag_ref.c
function (sofia_generate_tag_ref)
    # parse arguments
    cmake_parse_arguments(TAG "DLLREF;LIST" "PREFIX" "" ${ARGN})

    # parse file prefix
    if (TAG_PREFIX)
        set(_prefix ${TAG_PREFIX})
    else (TAG_PREFIX)
        string(REGEX REPLACE ".+/(.+)" "\\1" _prefix ${CMAKE_CURRENT_SOURCE_DIR})
    endif (TAG_PREFIX)

    # parse dll flags
    set(_dll_flags NODLL=1)
    if (${TAG_DLLREF})
        set(_dll_flags "${_dll_flags} DLLREF=1")
    endif (${TAG_DLLREF})
    if (${TAG_LIST})
        set(_dll_flags "${_dll_flags} LIST=${_prefix}_tag_list")
    endif (${TAG_LIST})

    # source file and target file
    set(_depends)
    set(_source ${CMAKE_CURRENT_SOURCE_DIR}/${_prefix}_tag.c)
    set(_target ${CMAKE_CURRENT_BINARY_DIR}/${_prefix}_tag_ref.c)
    set(_awk_file ${CMAKE_SOURCE_DIR}/libsofia-sip-ua/su/tag_dll.awk)
    if (NOT EXISTS ${_source})
        set(_source ${CMAKE_CURRENT_BINARY_DIR}/${_prefix}_tag.c)
        set(_depends ${_source})
    endif ()

    # add xxx_tag_ref.c target
    add_custom_command(
        OUTPUT ${_target}
        COMMAND ${AWK} -f ${_awk_file} NODLL=1 ${dll_flags} REF=${_target} ${_source}
        DEPENDS ${_depends}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )
endfunction (sofia_generate_tag_ref)
