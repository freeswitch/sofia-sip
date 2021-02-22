if (__AWK_INCLUDED)
    return()
endif (__AWK_INCLUDED)
set(__AWK_INCLUDED TRUE)

# find awk program
find_program(AWK awk mawk gawk)
if (AWK MATCHES ".+-NOTFOUND")
    message(FATAL_ERROR "FATAL: awk (and mawk and gawk) could not be found (${AWK}).")
endif ()
