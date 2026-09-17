#!/usr/bin/env bash
# Render every variant to STL with the OpenSCAD CLI:
# left and right halves, for each wall pattern (plain, hex, voronoi).
# Output: stl/kyria_stand_<pattern>_<side>.stl  ("plain" is pattern="none"), binary STL
set -euo pipefail
cd "$(dirname "$0")"

OPENSCAD="${OPENSCAD:-$(command -v openscad || true)}"
if [ -z "$OPENSCAD" ]; then
  for c in /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
           "$HOME/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"; do
    [ -x "$c" ] && OPENSCAD="$c" && break
  done
fi
[ -n "$OPENSCAD" ] || { echo "openscad not found; set OPENSCAD=/path/to/openscad" >&2; exit 1; }

# roof() is experimental; the Manifold backend is much faster where available.
EXTRA="--enable=roof --export-format=binstl"
if "$OPENSCAD" --help 2>&1 | grep -q -- '--backend'; then EXTRA="$EXTRA --backend=Manifold"; fi

mkdir -p stl
for pattern in none hex voronoi; do
  name=$pattern; [ "$pattern" = none ] && name=plain
  for side in left right; do
    out="stl/kyria_stand_${name}_${side}.stl"
    echo "== $out"
    "$OPENSCAD" $EXTRA -o "$out" -D "side=\"$side\"" -D "pattern=\"$pattern\"" kyria_stand.scad 2>&1 \
      | grep -E 'ECHO|WARNING|ERROR|Status' || true
  done
done
ls -la stl/
