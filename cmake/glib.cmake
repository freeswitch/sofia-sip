if (__GLIB_INCLUDED)
    return()
endif (__GLIB_INCLUDED)
set(__GLIB_INCLUDED TRUE)

set(WITH_GLIB_VERSION "2.0" CACHE STRING "use GLib (default=2.0)")

find_package(PkgConfig REQUIRED)
pkg_check_modules(GLIB glib-${WITH_GLIB_VERSION})

if (NOT GLIB_FOUND)
    return()
endif (NOT GLIB_FOUND)

set(HAVE_GLIB 1)
include_directories(${GLIB_INCLUDE_DIRS})
