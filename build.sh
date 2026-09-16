#!/usr/bin/env bash
# Render both halves to STL (and PNG previews) with the OpenSCAD CLI.
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

# Manifold backend is much faster where available (2024+ nightlies).
EXTRA="--enable=roof"
if "$OPENSCAD" --help 2>&1 | grep -q -- '--backend'; then EXTRA="--backend=Manifold --enable=roof"; fi

for side in left right; do
  out="kyria_stand_${side}.stl"
  echo "== $out"
  "$OPENSCAD" $EXTRA -o "$out" -D "side=\"$side\"" kyria_stand.scad
  "$OPENSCAD" $EXTRA -o "kyria_stand_${side}.png" -D "side=\"$side\"" \
      --render --view=edges --camera=5,0,20,35,0,25,520 --viewall \
      --imgsize=1200,900 --colorscheme=Cornfield kyria_stand.scad
done
ls -la kyria_stand_*.stl kyria_stand_*.png
