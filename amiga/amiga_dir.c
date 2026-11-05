/* AmigaDOS locks files as readily as drawers, and libnix's chdir() makes
 * whatever it locked the current directory: chdir("themes.tab") succeeds
 * and every relative open after it fails. Simutrans relies on chdir()
 * refusing a file (gui_theme.cc changes to the theme file's "drawer",
 * which for "themes.tab" is the file itself), so dr_chdir() asks this
 * first.
 * The AmiCradle Team. Artistic License, like Simutrans. */
#include <exec/types.h>
#include <dos/dos.h>
#include <proto/dos.h>

int amiga_is_drawer(const char *path)
{
	struct FileInfoBlock *fib;
	BPTR lock;
	int drawer = 0;

	lock = Lock((CONST_STRPTR)path, ACCESS_READ);
	if (!lock)
		return 0;
	fib = (struct FileInfoBlock *)AllocDosObject(DOS_FIB, NULL);
	if (fib) {
		if (Examine(lock, fib))
			drawer = fib->fib_DirEntryType > 0;
		FreeDosObject(DOS_FIB, fib);
	}
	UnLock(lock);
	return drawer;
}
