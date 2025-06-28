if (__INLINE_INCLUDED)
    return()
endif (__INLINE_INCLUDED)
set(__INLINE_INCLUDED TRUE)

include(CheckCSourceCompiles)

foreach (KEYWORD "inline" "__inline__" "__inline")
    set(_INLINE_SOURCE "
        typedef int foo_t;
        static ${KEYWORD} foo_t static_foo (void) {return 0; }
        ${KEYWORD} foo_t foo (void) {return 0; }
        int main() { return 0; }
    ")
    check_c_source_compiles("${_INLINE_SOURCE}" _${KEYWORD}_COMPLIED)
    if (_${KEYWORD}_COMPLIED)
        set(C_INLINE ${KEYWORD})
        break()
    endif (_${KEYWORD}_COMPLIED)
ENDFOREACH (KEYWORD)

# Whether inline
if (DEFINED C_INLINE)
    set(SU_HAVE_INLINE 1)
    set(SU_INLINE      ${C_INLINE})
    set(su_inline      "static ${C_INLINE}")
    if (ENABLE_TAG_CAST)
        set(SU_INLINE_TAG_CAST 1)
    endif (ENABLE_TAG_CAST)
else ()
    set(SU_HAVE_INLINE 0)
    set(SU_INLINE      /*inline*/)
    set(su_inline      static)
endif ()
