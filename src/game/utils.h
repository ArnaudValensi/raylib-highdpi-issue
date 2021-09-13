#pragma once

#ifdef __GNUC__
#  define UNUSED(x) UNUSED_ ## x __attribute__((__unused__))
#else
#  define UNUSED(x) UNUSED_ ## x
#endif

#ifdef __GNUC__
#  define UNUSED_FUNCTION(x) __attribute__((__unused__)) UNUSED_ ## x
#else
#  define UNUSED_FUNCTION(x) UNUSED_ ## x
#endif

void check_handler(char *condition, char *function, char *file, int line);

#define check( condition )                                                       \
do                                                                               \
{                                                                                \
    if ( !(condition) )                                                          \
    {                                                                            \
        check_handler( #condition, (char*) __FUNCTION__, __FILE__, __LINE__ );   \
    }                                                                            \
} while(0)
