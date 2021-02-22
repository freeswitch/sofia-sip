if (__PTHREAD_INCLUDED)
    return()
endif (__PTHREAD_INCLUDED)
set(__PTHREAD_INCLUDED TRUE)

include(utils)

sofia_include_file(pthread.h)
if (NOT HAVE_PTHREAD_H)
    return()
endif (NOT HAVE_PTHREAD_H)

link_libraries(pthread)
sofia_library_exists(pthread pthread_create)

# Define if you have pthread_setschedparam()
sofia_library_exists(pthread pthread_setschedparam HAVE_PTHREAD_SETSCHEDPARAM)

set(CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES} pthread)
sofia_source_runs("
    pthread_rwlock_t rw;
    int main() {
      pthread_rwlock_init(&rw, NULL);
      pthread_rwlock_rdlock(&rw);
      pthread_rwlock_rdlock(&rw);
      pthread_rwlock_unlock(&rw);
      /* pthread_rwlock_trywrlock() should fail (not return 0) */
      return pthread_rwlock_trywrlock(&rw) != 0 ? 0  : 1;
    }
    " HAVE_PTHREAD_RWLOCK)
