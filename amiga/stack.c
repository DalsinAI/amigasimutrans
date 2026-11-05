/* A Shell gives 4 KB of stack; libnix's startup swaps to this much instead.
 * Simutrans runs its Squirrel scripts (the AI players, scenarios, the
 * tutorial) and its recursive path and network searches on the game's
 * own task.
 * The AmiCradle Team. Artistic License, like Simutrans. */
unsigned long __stack = 1024 * 1024;
static const char version[] __attribute__((used)) = "$VER: Simutrans 125.0.1 Amiga (05.11.2026)";
