add_library(bnf STATIC bnf.c)

if (NOT ENABLE_TESTS AND NOT ENABLE_BNF_TESTS)
    return()
endif (NOT ENABLE_TESTS AND NOT ENABLE_BNF_TESTS)

add_executable(torture_bnf torture_bnf.c)
target_link_libraries(torture_bnf bnf su)
add_test(torture_bnf torture_bnf)
