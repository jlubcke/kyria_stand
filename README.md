# Kyria tenting stand

Open-shell tenting tray for a splitkb Kyria rev3 half: perimeter wall plus a
sloped floor, no bottom. The case drops into the pocket. Modelled in OpenSCAD
from the official bottom-plate DXF.

## Files

- `kyria_stand.scad` – the model, all parameters at the top
- `Kyria rev3 Bottom Plate - No Kerf.dxf` – case outline, imported directly
- `build.sh` – renders `kyria_stand_left.stl`, `kyria_stand_right.stl` and PNG previews
- `kyria_stand_*.stl` – ready to slice

## Defaults

| parameter      | value  | meaning                                  |
| -------------- | ------ | ---------------------------------------- |
| `inner_height` | 50 mm  | rim height at the inner (thumb/OLED) edge |
| `lip`          | 4 mm   | wall above the floor                     |
| `wall`         | 2.5 mm | wall thickness                           |
| `floor_t`      | 2.5 mm | floor thickness                          |
| `clearance`    | 0.4 mm | gap between case and pocket wall         |

Resulting tent angle is about 15°. Outer rim is 6.5 mm tall.
Footprint per half: roughly 167 × 120 mm.

`side = "right"` is the DXF as drawn (inner edge on -X, seen from above);
`side = "left"` mirrors it. If the halves come out swapped, just swap the files.

## Rebuild

```bash
./build.sh
```

Needs OpenSCAD on the PATH (`brew install --cask openscad@snapshot`).

## Printing

There is no bottom, so printed upright the floor is a ~15° roof over an open
cavity and needs supports. Alternatives: print on its side standing on the long
straight outer wall, or set `floor_t` thicker and accept supports.
