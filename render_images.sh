#!/usr/bin/env bash
# Re-render the README images, one per wall pattern.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p images
for pat in none hex voronoi; do
  openscad --enable=roof --backend=Manifold --render -o "images/pattern_$pat.png" \
      -D 'side="right"' -D "pattern=\"$pat\"" \
      --projection=p --camera=5,0,15,65,0,35,420 --imgsize=1200,800 \
      --colorscheme=Tomorrow kyria_stand.scad
done
