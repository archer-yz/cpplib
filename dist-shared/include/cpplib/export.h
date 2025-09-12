
#ifndef CPPLIB_EXPORT_H
#define CPPLIB_EXPORT_H

#ifdef CPPLIB_STATIC
#  define CPPLIB_EXPORT
#  define CPPLIB_NO_EXPORT
#else
#  ifndef CPPLIB_EXPORT
#    ifdef cpplib_EXPORTS
        /* We are building this library */
#      define CPPLIB_EXPORT __declspec(dllexport)
#    else
        /* We are using this library */
#      define CPPLIB_EXPORT __declspec(dllimport)
#    endif
#  endif

#  ifndef CPPLIB_NO_EXPORT
#    define CPPLIB_NO_EXPORT 
#  endif
#endif

#ifndef CPPLIB_DEPRECATED
#  define CPPLIB_DEPRECATED __declspec(deprecated)
#endif

#ifndef CPPLIB_DEPRECATED_EXPORT
#  define CPPLIB_DEPRECATED_EXPORT CPPLIB_EXPORT CPPLIB_DEPRECATED
#endif

#ifndef CPPLIB_DEPRECATED_NO_EXPORT
#  define CPPLIB_DEPRECATED_NO_EXPORT CPPLIB_NO_EXPORT CPPLIB_DEPRECATED
#endif

#if 0 /* DEFINE_NO_DEPRECATED */
#  ifndef CPPLIB_NO_DEPRECATED
#    define CPPLIB_NO_DEPRECATED
#  endif
#endif

#endif /* CPPLIB_EXPORT_H */
