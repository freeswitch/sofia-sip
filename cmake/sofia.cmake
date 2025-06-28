if (__SOFIA_INCLUDED)
    return()
endif (__SOFIA_INCLUDED)
set(__SOFIA_INCLUDED TRUE)

include(utils)

option(ENABLE_IP6 "enable IPv6 functionality (enabled)" ON)

# static definitions
set(HAVE_SOFIA_SIP     1)
set(HAVE_SOFIA_SRESOLV 1)
set(HAVE_SOFIA_SMIME   0)

# Check whether include headers exists
sofia_include_file(stdio.h)
sofia_include_file(stdlib.h)
sofia_include_file(stddef.h)
sofia_include_file(string.h)
sofia_include_file(strings.h)
sofia_include_file(signal.h)
sofia_include_file(stdint.h)
sofia_include_file(inttypes.h)
sofia_include_file(unistd.h)
sofia_include_file(sys/time.h)
sofia_include_file(fcntl.h)
sofia_include_file(dlfcn.h)
sofia_include_file(dirent.h)
sofia_include_file(sys/socket.h)
sofia_include_file(sys/types.h)
sofia_include_file(sys/ioctl.h)
sofia_include_file(sys/filio.h)
sofia_include_file(sys/sockio.h)
sofia_include_file(sys/select.h)
sofia_include_file(sys/epoll.h)
sofia_include_file(sys/devpoll.h)
sofia_include_file(sys/stat.h)
sofia_include_file(netdb.h)
sofia_include_file(netinet/in.h)
sofia_include_file(netinet/sctp.h)
sofia_include_file(netinet/tcp.h)
sofia_include_file(arpa/inet.h)
sofia_include_file(net/if.h)
sofia_include_file(net/if_types.h)
sofia_include_file(ifaddr.h)
sofia_include_file(netpacket/packet.h)
sofia_include_file(winsock2.h)
sofia_include_file(windef.h)
sofia_include_file(ws2tcpip.h)
sofia_include_file(iphlpapi.h)
sofia_include_file(alloca.h)
sofia_include_file(fnmatch.h)

# Check whether symbol or function exists
sofia_symbol_exists(memmem)
sofia_symbol_exists(memspn)
sofia_symbol_exists(memcspn)
sofia_symbol_exists(memccpy)
sofia_symbol_exists(getopt)
sofia_symbol_exists(clock_getcpuclockid)
sofia_symbol_exists(clock_gettime)
sofia_symbol_exists(epoll_create)
sofia_symbol_exists(poll)
sofia_symbol_exists(socket)
sofia_symbol_exists(flock)
sofia_symbol_exists(freeaddrinfo)
sofia_symbol_exists(alloca)
sofia_symbol_exists(alarm)
sofia_symbol_exists(__func__     HAVE_FUNC)
sofia_symbol_exists(__FUNCTION__ HAVE_FUNCTION)
sofia_symbol_exists(gai_strerror)
sofia_symbol_exists(getaddrinfo)
sofia_symbol_exists(getdelim)
sofia_symbol_exists(gethostbyname)
sofia_symbol_exists(gethostname)
sofia_symbol_exists(getifaddrs)
sofia_symbol_exists(getipnodebyname)
sofia_symbol_exists(getline)
sofia_symbol_exists(getnameinfo)
sofia_symbol_exists(getpass)
sofia_symbol_exists(gettimeofday)
sofia_symbol_exists(if_nameindex)
sofia_symbol_exists(inet_ntop)
sofia_symbol_exists(inet_pton)
sofia_symbol_exists(initstate)
sofia_symbol_exists(kqueue)
sofia_symbol_exists(random)
sofia_symbol_exists(select)
sofia_symbol_exists(signal)
sofia_symbol_exists(socketpair)
sofia_symbol_exists(strerror)
sofia_symbol_exists(strnlen)
sofia_symbol_exists(strtoull)
sofia_symbol_exists(tcsetattr)
sofia_symbol_exists(MSG_TRUNC HAVE_MSG_TRUNC)

# Check whether type exists
sofia_type_exists("const int"                      HAVE_CONST)
sofia_type_exists("struct addrinfo"                HAVE_ADDRINFO)
sofia_type_exists("long long"                      HAVE_LONG_LONG)
sofia_type_exists("struct sockaddr_storage"        HAVE_SOCKADDR_STORAGE)
sofia_type_exists("struct addrinfo"                HAVE_ADDRINFO)
sofia_library_exists(z compress                    HAVE_ZLIB)
sofia_library_exists(dl dlopen                     HAVE_LIBDL)
sofia_struct_has_member("struct sockaddr" "sa_len" HAVE_SA_LEN)

# Check whether have in6 in
if (ENABLE_IP6)
    sofia_type_exists("struct sockaddr_in6" HAVE_SIN6)
    if (HAVE_SIN6)
        set(SU_HAVE_IN6 1)
    endif (HAVE_SIN6)
endif (ENABLE_IP6)

# Check whether epoll interface
if (HAVE_EPOLL_CREATE AND HAVE_SYS_EPOLL_H)
    set(HAVE_EPOLL 1)
endif ()
if (HAVE_POLL)
    set(HAVE_POLL_PORT 1)
endif (HAVE_POLL)

# Check Whether have zlib
if (HAVE_ZLIB)
    link_libraries(z)
    set(HAVE_ZLIB_COMPRESS 1)
endif (HAVE_ZLIB)

# Define to empty if `const' does not conform to ANSI C.
if (NOT HAVE_CONST)
    set(const " ")
endif (NOT HAVE_CONST)

# Define size_t to `unsigned int' if <sys/types.h> does not define.
if (NOT HAVE_SYS_TYPES_H)
    set(size_t "unsigned int")
endif (NOT HAVE_SYS_TYPES_H)

# Check whether long long type
if (HAVE_LONG_LONG)
    set(longlong "long long")
endif (HAVE_LONG_LONG)

# Check whether /dev/urandom device
execute_process(COMMAND test -r /dev/urandom ERROR_VARIABLE TEST_URANDOM_ERROR)
if (NOT TEST_URANDOM_ERROR)
    set(DEV_URANDOM      1)
    set(HAVE_DEV_URANDOM 1)
endif ()

# Check whether c99 'size specifiers' supported
sofia_source_runs("
    int main() {
        char buf[64];
        if (sprintf(buf, \"%lld%hhd%jd%zd%td\", (long long int)1, (char)2, (intmax_t)3, (size_t)4, (ptrdiff_t)5) != 5) {
            return 1;
        }
        return strcmp(buf, \"12345\");
    }
" HAVE_C99_FORMAT)
if (HAVE_C99_FORMAT)
    set(LLU    %llu)
    set(LLI    %lli)
    set(LLX    %llx)
    set(MOD_ZD %zd)
    set(MOD_ZU %zu)
else (HAVE_C99_FORMAT)
    sofia_source_runs("
        int main() {
            char buf[64];
            if (sprintf(buf, \"%lld\", (long long int)1) != 1) return 1;
            return strcmp(buf, \"1\");
        }
    " HAVE_LL_FORMAT)
    sofia_source_runs("
        int main() {
            char buf[64];
            if (sprintf(buf, \"%zd\", (size_t)1) != 1) return 1;
            return strcmp(buf, \"1\");
        }
    " HAVE_Z_FORMAT)
    if (NOT HAVE_LL_FORMAT)
        message(FATAL_ERROR "printf cannot handle 64-bit integers")
    endif (NOT HAVE_LL_FORMAT)
    if (NOT HAVE_Z_FORMAT)
        message(WARNING "printf cannot handle size_t, using long instead")
    endif (NOT HAVE_Z_FORMAT)

    set(LLU    %llu)
    set(LLI    %lli)
    set(LLX    %llx)
    set(MOD_ZD %ld)
    set(MOD_ZU %lu)
endif (HAVE_C99_FORMAT)

# Check RETSIGTYPE
sofia_source_runs("
    int main() {
        return *(signal (0, 0)) (0) == 1;
    }
" HAVE_TYPE_SIGNAL_INT)
if (HAVE_TYPE_SIGNAL_INT)
    set(RETSIGTYPE int)
else (HAVE_TYPE_SIGNAL_INT)
    set(RETSIGTYPE void)
endif (HAVE_TYPE_SIGNAL_INT)
