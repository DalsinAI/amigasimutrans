/* Included before every upstream file (-include).
 * libstdc++'s thread layer includes the toolchain's <pthread.h>, which,
 * if <unistd.h> came first, turns read(), write(), close() ... into
 * macros (cancellation points); Simutrans' streams have methods of those
 * names. Taken first, <pthread.h> leaves them alone.
 * The AmiCradle Team. Artistic License, like Simutrans. */
#ifdef __cplusplus
#include <pthread.h>
#endif

/* libnix has no ftello()/fseeko() (miniz, for the pakset downloader, asks
 * for them); files here are never over 2 GB. */
#include <stdio.h>
#define ftello ftell
#define fseeko fseek
