#!/bin/sh

BOLD="\033[1m"
GREEN="\033[0;32m"
OFF="\033[m"
NAME="fuzic"
SRC="./src/main.sh"

tmpdir=$(mktemp -d)
echo "🥚 ${GREEN}Internalize sourced files${OFF}"
sed -E 's|\. "([^$].+)"$|cat src/\1|e' "$SRC" >"$tmpdir/1.sh"
echo "🐔 ${GREEN}Internalize awk scripts${OFF}"
sed -E 's|@@include (.+)$|cat src/\1|e' "$tmpdir/1.sh" >"$tmpdir/2.sh"
echo "🥚 ${GREEN}Internalize awk libraries${OFF}"
sed -E 's|@include "(.+)"$|cat src/\1|e' "$tmpdir/2.sh" >"$tmpdir/3.sh"
echo "🐔 ${GREEN}Strip comments${OFF}"
grep -v "^ *# " "$tmpdir/3.sh" | grep -v "^ *#$" >"$NAME"
echo "🥚 ${GREEN}Make executable and cleanup${OFF}"
chmod +x "$NAME"
rm -rf "$tmpdir"
echo "🍳 ${GREEN}Done:${OFF} Sucessfully built ${BOLD}${GREEN}$NAME${OFF}"
