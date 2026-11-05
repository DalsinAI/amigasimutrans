#!/bin/sh
# Cross-builds the static libraries the Team's ports share (zlib, libpng,
# IJG jpeg, sqlite3, libxml2) for AmigaOS 3.x, 68040/68060 + FPU, libnix,
# into $PREFIX (include/ and lib/). Run one library at a time:
#   sh build-m68k-libs.sh zlib|png|jpeg|sqlite|xml2|bzip2|freetype
# Simutrans adds bzip2 (its saved games) and FreeType (its fonts): their
# release tarballs are kept beside this script and unpacked into $DEPS.
# -j2 at most: the build machine is short of memory.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
STOVE=${STOVE:-$HOME/CradleLab/toolchain/openamigagcc-16.2.0-open4-x86_64-linux}
DEPS=${DEPS:-/mnt/amigachrome/team2/deps}
PREFIX=${PREFIX:-$DEPS/m68k-amigaos}
CC=$STOVE/bin/m68k-amigaos-gcc
AR=$STOVE/bin/m68k-amigaos-ar
RANLIB=$STOVE/bin/m68k-amigaos-ranlib
CFLAGS="-noixemul -m68040 -m68881 -O2 -fomit-frame-pointer -fno-tree-loop-distribute-patterns"
mkdir -p $PREFIX/include $PREFIX/lib

objs() { # dir lib files...
  d=$1; lib=$2; shift 2
  rm -rf $d/.m68k; mkdir -p $d/.m68k
  for f in "$@"; do
    $CC $CFLAGS $EXTRA -I$d -I$PREFIX/include -c $d/$f -o $d/.m68k/$(basename $f .c).o
  done
  rm -f $PREFIX/lib/$lib
  $AR rcs $PREFIX/lib/$lib $d/.m68k/*.o
  $RANLIB $PREFIX/lib/$lib
}

case "$1" in
zlib)
  d=$DEPS/zlib-1.3.1
  EXTRA="-DHAVE_UNISTD_H -DHAVE_STDARG_H"
  objs $d libz.a adler32.c compress.c crc32.c deflate.c gzclose.c gzlib.c \
       gzread.c gzwrite.c infback.c inffast.c inflate.c inftrees.c trees.c \
       uncompr.c zutil.c
  cp $d/zlib.h $d/zconf.h $PREFIX/include/
  ;;
png)
  d=$DEPS/libpng-1.6.43
  cp $d/scripts/pnglibconf.h.prebuilt $d/pnglibconf.h
  EXTRA="-DPNG_ARM_NEON_OPT=0"
  objs $d libpng.a png.c pngerror.c pngget.c pngmem.c pngpread.c pngread.c \
       pngrio.c pngrtran.c pngrutil.c pngset.c pngtrans.c pngwio.c pngwrite.c \
       pngwtran.c pngwutil.c
  cp $d/png.h $d/pngconf.h $d/pnglibconf.h $PREFIX/include/
  ;;
jpeg)
  d=$DEPS/jpeg-9f
  cp $d/jconfig.txt $d/jconfig.h
  EXTRA=""
  objs $d libjpeg.a jaricom.c jcapimin.c jcapistd.c jcarith.c jccoefct.c \
       jccolor.c jcdctmgr.c jchuff.c jcinit.c jcmainct.c jcmarker.c jcmaster.c \
       jcomapi.c jcparam.c jcprepct.c jcsample.c jctrans.c jdapimin.c \
       jdapistd.c jdarith.c jdatadst.c jdatasrc.c jdcoefct.c jdcolor.c \
       jddctmgr.c jdhuff.c jdinput.c jdmainct.c jdmarker.c jdmaster.c \
       jdmerge.c jdpostct.c jdsample.c jdtrans.c jerror.c jfdctflt.c \
       jfdctfst.c jfdctint.c jidctflt.c jidctfst.c jidctint.c jquant1.c \
       jquant2.c jutils.c jmemmgr.c jmemnobs.c
  cp $d/jpeglib.h $d/jconfig.h $d/jmorecfg.h $d/jerror.h $PREFIX/include/
  ;;
sqlite)
  d=$DEPS/sqlite-amalgamation-3460100
  # sqlite3_amiga.c: the amalgamation with its mutexes on Exec semaphores
  # and its own VFS (amiga_vfs.c: dos.library's file calls, SQLite's locks
  # kept in memory for all of the program's connections). sqlite3_patched.c lets SQLITE_MUTEX_APPDEF keep SQLite from
  # picking its no-op mutexes for an OS it does not know.
  python3 - "$d/sqlite3.c" "$d/sqlite3_patched.c" <<'PY'
import sys
s = open(sys.argv[1]).read()
old = "#  else\n#    define SQLITE_MUTEX_NOOP\n#  endif\n"
new = "#  elif !defined(SQLITE_MUTEX_APPDEF)\n#    define SQLITE_MUTEX_NOOP\n#  endif\n"
assert s.count(old) == 1
open(sys.argv[2], "w").write(s.replace(old, new))
PY
  # Thread-safe; no shared memory, no mmap, no loadable extensions; temp
  # tables in memory.
  EXTRA="-DSQLITE_THREADSAFE=1 -DSQLITE_MUTEX_APPDEF=1 -DSQLITE_OMIT_LOAD_EXTENSION -DSQLITE_OMIT_WAL \
 -DSQLITE_MAX_MMAP_SIZE=0 -DSQLITE_OMIT_SHARED_CACHE -DSQLITE_ENABLE_LOCKING_STYLE=0 \
 -DSQLITE_DEFAULT_MEMSTATUS=0 -DSQLITE_OMIT_PROGRESS_CALLBACK \
 -DSQLITE_TEMP_STORE=3 -DSQLITE_OS_OTHER=1"
  objs $d libsqlite3.a sqlite3_amiga.c
  cp $d/sqlite3.h $PREFIX/include/
  ;;
xml2)
  # libxml2's own configure, cut down to the parser and the tree (no
  # threads, HTTP/FTP, iconv, ICU, zlib, lzma, catalogs, modules ...).
  d=$DEPS/libxml2-2.12.9
  ( cd $d && PATH=$STOVE/bin:$PATH CC=m68k-amigaos-gcc AR=m68k-amigaos-ar \
    RANLIB=m68k-amigaos-ranlib CFLAGS="$CFLAGS" LDFLAGS="-noixemul" \
    ./configure --host=m68k-amigaos --prefix=$PREFIX --disable-shared \
      --enable-static --without-python --without-threads \
      --without-thread-alloc --without-http --without-ftp --without-iconv \
      --without-icu --without-zlib --without-lzma --without-catalog \
      --without-modules --without-debug --without-readline \
      --without-history --without-schematron --without-xinclude \
      --without-xptr --without-c14n --without-legacy && \
    PATH=$STOVE/bin:$PATH make -j2 libxml2.la )
  cp $d/.libs/libxml2.a $PREFIX/lib/
  mkdir -p $PREFIX/include/libxml2
  rm -rf $PREFIX/include/libxml2/libxml
  cp -r $d/include/libxml $PREFIX/include/libxml2/
  rm -f $PREFIX/include/libxml2/libxml/Makefile* $PREFIX/include/libxml2/libxml/*.in
  ;;
bzip2)
  # bzip2 1.0.8 (sourceware.org, sha256 ab5a0317...), the library only.
  d=$DEPS/bzip2-1.0.8
  [ -d $d ] || tar -xzf $HERE/bzip2-1.0.8.tar.gz -C $DEPS
  EXTRA=""
  objs $d libbz2.a blocksort.c huffman.c crctable.c randtable.c compress.c \
       decompress.c bzlib.c
  cp $d/bzlib.h $PREFIX/include/
  ;;
freetype)
  # FreeType 2.13.3 (savannah, sha256 05503506...), with the modules of
  # freetype/ftmodule.h only: TrueType, BDF, sfnt, psnames, the two
  # rasterisers, ftmm (sfnt calls it) and ftgzip with its own zlib (WOFF).
  # No bzip2, PNG, HarfBuzz or Brotli.
  d=$DEPS/freetype-2.13.3
  [ -d $d ] || tar -xJf $HERE/freetype-2.13.3.tar.xz -C $DEPS
  EXTRA="-I$d/include -I$HERE/freetype -DFT2_BUILD_LIBRARY -DFT_CONFIG_MODULES_H=<ftmodule.h>"
  objs $d libfreetype.a src/base/ftsystem.c src/base/ftinit.c src/base/ftdebug.c \
       src/base/ftbase.c src/base/ftglyph.c src/base/ftbitmap.c src/base/ftbbox.c \
       src/truetype/truetype.c src/sfnt/sfnt.c src/psnames/psnames.c \
       src/base/ftmm.c src/gzip/ftgzip.c \
       src/bdf/bdf.c src/smooth/smooth.c src/raster/raster.c
  rm -rf $PREFIX/include/freetype2
  mkdir -p $PREFIX/include/freetype2
  cp -r $d/include/ft2build.h $d/include/freetype $PREFIX/include/freetype2/
  cp $HERE/freetype/ftmodule.h $PREFIX/include/freetype2/freetype/config/ftmodule.h
  ;;
*)
  echo "usage: $0 zlib|png|jpeg|sqlite|xml2|bzip2|freetype" >&2; exit 1 ;;
esac
echo "built $1 into $PREFIX"
