Simutrans for AmigaOS 3.x
=========================

Simutrans 125.0.1 (upstream https://github.com/simutrans/simutrans, tag
125.0.1, commit 40bbb12894793cc7c6ae5c93f31a16e7e7707627; the Artistic
License, see LICENSE.txt), the open-source transport simulation, for
AmigaOS 3.2 on a 68040 or 68060 with an FPU, on OpenGPU's SDL 2, with the
pak64 graphics set.

Status: runs in the lab (AmigaChrome, OpenGPU 0.6): main menu with pak64,
a new 64x64 map, building rail, saving, loading it back and quitting to
the Workbench with no screen left behind.


What you need
-------------

- AmigaOS 3.2 (or 3.2.3 with GFOpenUp), a 68040/68060 with an FPU.
- An RTG screen mode of 640x480 (or what -screensize asks for) in 16 or
  32-bit colour that SDL 2 can open.
- OpenGPU's runtime, which OpenUp installs: opengpu.library and
  LIBS:OpenGPU/SDL2.module (picture, keyboard, mouse and sound, through AHI).
- Fast RAM: 128 MB (a small game uses about 70 MB; see Memory below).
- About 30 MB of disk.


Using it
--------

Open the Simutrans icon, or run it from a Shell (it finds its data through
PROGDIR:, so from any directory). Everything it writes stays in its drawer:
settings.xml, save/ (saved games), screenshot/ and maps/ (heightmaps).

It starts on a 640x480 16-bit screen of its own, with pak64 and without the
pakset choice. Shell arguments are upstream's, for instance:

    Simutrans -screensize 800x600       another screen size
    Simutrans -lang de                  another language (en de fr es it nl sv pl)
    Simutrans -load save/game.sve       straight into a saved game
    Simutrans -log 1 -debug 3           write simu.log in the drawer

Start a small map: New Game, map size 128x128 (or 64x64) with a few towns.
The defaults the drawer sets are in config/simuconf.tab, at the top (from
amiga/simuconf-amiga.tab): fullscreen = 0 there gives a window on the
Workbench instead (which then must be a 16 or 32-bit RTG screen).

Left out:

- Network games, the server list and the pakset download: the build has no
  network (below).
- Music: Simutrans plays MIDI through the system's MIDI player, which
  AmigaOS 3 does not have; upstream's no_midi.cc is used. The music
  drawer is not in the game drawer. Sound effects play through SDL 2.
- zstd saves (bzip2 and zlib ones work; the drawer saves with zlib, which is
  faster than bzip2 on a 68k), UPnP, fontconfig, threads.
- Translations: the drawer has English, German, French, Spanish, Italian,
  Dutch, Swedish and Polish. Simutrans reads every .tab in text/ (and in
  pak/text/) at start-up and keeps them all in memory; any other upstream
  text/*.tab and its help drawer can be copied in.



Standard keys
-------------

Every AmiCradle game has the same keys on Right Amiga (GFOpenUp's
SDL2.module, after 0.8.26):

- Right Amiga + F: window or full screen, remembered for next time
- Right Amiga + P: pause (Right Amiga + P again goes on)
- Right Amiga + Q: quit
- Right Amiga + M: free the mouse pointer, or let the game take it again
- Right Amiga + S: a screenshot in the drawer's Screenshots
- Help: this game's keys (the drawer's Controls file)
- Right Amiga + F1, F2: F11, F12; Right Amiga + cursor keys: Page Up,
  Page Down, Home, End

The FULLSCREEN tooltype on the game's icon (take the brackets off) starts
it full screen.


Data
----

pak64 is the standard, free 64-pixel graphics set: simupak64-125-0.zip
from Simutrans' official download (sourceforge.net/projects/simutrans,
pak64/125-0, sha256 850108b76505ca306822b88c22a1829c7102a6c9d7390c057f533ba70d9ecdad),
unpacked into pak/. Its licence: the Simutrans Team's, the Artistic License
(as Simutrans itself; the zip carries no licence file, the pak64 sources'
license.txt says so), except three pictures under the GNU GPL v3:
vehicles/water/abo-ships.png (by stormoog), player/road-depot-crystal.png
and the tropical park COM_12_04 (by vilvoh). It is the smallest of the
complete paksets (64x64 tiles, about 14 MB unpacked) and the only one that
fits a 68k's memory.

Simutrans' own data, from upstream's simutrans/ drawer: config/, font/ (the
BDF fonts), text/ (the languages above), themes/, script/ and ai/ (the
Squirrel scripts of the AI players and scenarios).


Memory
------

Measured in the lab: about 69 MB of Fast RAM in use during a 64x64 game
(free Fast RAM 449 MB in the game, 518 MB after quitting). So 128 MB of
Fast RAM is the practical minimum. Where it goes:
- pak64: every picture is kept in memory, as 16-bit run-length data (about
  12 MB), with its descriptions, the vehicle and building tables, and the
  sounds (about 2 MB of WAV, converted to SDL's output format).
- the screen: 640x480 16-bit (600 KB) and SDL's texture of it (600 KB, or
  1.2 MB if SDL 2 converts it to 32 bits), Simutrans' colour tables (about
  130 KB).
- the translations: the eight languages (about 1 MB with the pak's).
- the map: a 128x128 map is some 3-6 MB of tiles, ways, towns and
  vehicles; 256x256 four times that. Bigger maps on a 68k are slow anyway.
- the program itself (7.6 MB of code and data) and a 1 MB stack
  (amiga/stack.c: Squirrel, the AI and the path searches are recursive).


How it is built
---------------

Simutrans draws in 16 bits (RGB565) into its own buffer and shows it with
SDL 2: a window, a renderer and a streaming RGB565 texture
(src/simutrans/sys/simsys_s2.cc, upstream's sdl2 backend, used as it is but
for the changes below). It asks SDL for the RGB565 texture whatever the
window reports, so OpenGPU's 24-bit window (as in Seven Kingdoms' OVGA fix)
does not matter here. Sound: upstream's sound/sdl2_sound.cc (WAV, mixed in
SDL's audio callback).

Dependencies (static, -noixemul, libnix):

- SDL 2: the OpenGPU kit (libSDL2.a, the program's half of SDL2.module).
- zlib and libpng: the Team's shared ones.
- bzip2 1.0.8 and FreeType 2.13.3: amiga/deps/build-m68k-libs.sh (the
  Team's script with these two added; their release tarballs are in
  amiga/deps/). FreeType is cut down to the TrueType, BDF, sfnt and psnames
  modules, its two rasterisers, ftmm and ftgzip (amiga/deps/freetype/ftmodule.h):
  Simutrans reads even its own BDF fonts through FreeType.
- Squirrel 3: inside upstream (src/squirrel).
- libstdc++ asks for POSIX threads: amiga/pthread_stubs.c (one thread;
  this build of Simutrans starts none, MULTI_THREAD is off).
- The network: AmigaOS 3 has no socket headers in libnix. amiga/include/
  has just enough of them (sys/socket.h, netinet/, arpa/inet.h, netdb.h) for
  upstream's network code to build unchanged, and amiga/net_stubs.c fails
  every call as a machine with no TCP/IP stack would; Simutrans says it
  cannot connect and carries on.

Build (GFOpenAmigaGCC 16.2.0-open4 or later; the defaults are CradleLab's
paths):

    sh amiga/deps/build-m68k-libs.sh bzip2      # once, one at a time
    sh amiga/deps/build-m68k-libs.sh freetype   # (zlib and png likewise)
    make -f amiga/Makefile.amigaos -j2 \
         STOVE=$HOME/CradleLab/toolchain/openamigagcc-16.2.0-open4-x86_64-linux \
         NDK=$HOME/CradleLab/gfopensdk/OpenNDK/Include_H \
         SDL2KIT=/mnt/amigachrome/team2/deps/opengpu-sdk \
         DEPS=/mnt/amigachrome/team2/deps/m68k-amigaos
    make -f amiga/Makefile.amigaos dist \
         PAK64ZIP=/path/to/simupak64-125-0.zip

Output: build/amigaos/Simutrans (stripped; Simutrans.debug beside it has
the symbols), and with dist the game drawer dist/Simutrans/ with
dist/Simutrans.info. The source list is upstream's Makefile's (its common
SOURCES lines, read by the Amiga Makefile) plus the sdl2 backend's files.
Flags: -noixemul -m68040 -m68881 -O2 -std=gnu++14, GCC 16's
-fno-tree-loop-distribute-patterns, -DSIM_BIG_ENDIAN -DCOLOUR_DEPTH=16.
The build machine is short of memory: -j2 at most (no single file needs
more than about 250 MB to compile).

Icons: amiga/icons/icons.json, from our own GlowIcon art
(amiga/icons/art/simutrans.svg):

    python3 AMICRADLE/scripts/port_icons.py amiga/icons/icons.json --out amiga/icons


Byte order
----------

Simutrans has run on big-endian machines (PowerPC Macs, the old Amiga
target in its Makefile) and builds for them with -DSIM_BIG_ENDIAN:

- paks: obj_reader's decode_uint16/32/64 read little-endian byte by byte;
  image data is copied 16 bits at a time with a swap under SIM_BIG_ENDIAN
  (descriptor/reader/obj_reader.h).
- saved games and settings.xml: loadsave_t swaps every 16, 32 and 64-bit
  number under SIM_BIG_ENDIAN, binary, zlib, bzip2 and XML alike; so saved
  games are the PC's and move between the two.
- heightmaps (BMP) and screenshots: raw_image_bmp.cc swaps the headers.
- sha1 (the pak checksums) and the drawing code's 32-bit copies have their
  own big-endian branches.
- One upstream bug fixed: memory_rw_t::rdwr_longlong() (network/memory_rw.cc)
  swapped an uninitialised value instead of the one to write under
  SIM_BIG_ENDIAN. It serialises tool settings (simmenu, simtool) and the
  network commands.


Changes to upstream
-------------------

All under #ifdef __amigaos__, but the memory_rw.cc fix:

- sys/simsys.cc: the base, install and user drawers are PROGDIR:'s (no
  HOME); a drawer at a volume's root gets no '/' after its ':'; no
  realpath(); no pakset download script; fonts are looked for in
  PROGDIR:font/ and FONTS:.
- sys/simsys.cc, dr_chdir(): AmigaDOS locks a file as readily as a drawer,
  and libnix's chdir() then makes the file the current directory.
  gui_theme.cc changes to the theme file's "drawer", which for themes.tab
  is the file itself; on Linux chdir() refuses it, here every relative open
  after it failed and no theme images loaded ("Wrong theme loaded").
  dr_chdir() now refuses anything that is not a drawer (amiga/amiga_dir.c).
- utils/searchfolder.cc: AmigaDOS has no "." entry, and libnix no dirfd()
  or fstatat().
- sys/simsys_s2.cc: fullscreen is a screen of its own (SDL_WINDOW_FULLSCREEN)
  in the size asked for, not the Workbench's size; the screens SDL2.module
  0.6 leaves behind after a fullscreen window are closed after SDL_Quit()
  (amiga/amiga_screens.c, as in the Seven Kingdoms and X-Moto ports); a
  start from the Workbench (no arguments) gets a program name.
- simtypes.h: no 64-byte alignment (Amiga objects align to 8 at most).
- amiga/amiga_prelude.h, included first: the toolchain's <pthread.h> turns
  read(), write() and close() into macros if <unistd.h> came before it;
  taken first, it does not. It also maps ftello()/fseeko(), which libnix
  lacks, to ftell()/fseek() (miniz, inside upstream).


What a tester should check first
--------------------------------

1. It starts from the icon and from a Shell in another drawer: the
   640x480 screen opens, the pak64 loading bar runs (it takes a while on a
   68k), and the main menu shows with the right colours.
2. A new 128x128 game: the map draws, scrolling works, a road, a bus stop
   and a bus can be built and the bus runs; sound effects play.
3. Saving and loading (save/ in the drawer); a saved game from a PC loads.
4. Quitting returns to the Workbench with no grey screen left behind.
5. Memory: AvailMem before, after the main menu and during a game.
6. -screensize 800x600, and fullscreen = 0 for a window on the Workbench.
