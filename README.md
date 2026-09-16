# Kyria tenting stand

Tenting stand for a splitkb Kyria rev3 half: a perimeter wall following the
case outline with a small inward ledge the bottom plate rests on. No floor, no
bottom. The ledge underside is sloped so it prints upright with no supports.
Modelled in OpenSCAD from the official bottom-plate DXF.

## Files

- `kyria_stand.scad` – the model, all parameters at the top
- `Kyria rev3 Bottom Plate - No Kerf.dxf` – case outline, imported directly
- `build.sh` – renders `kyria_stand_left.stl`, `kyria_stand_right.stl` and PNG previews
- `kyria_stand_*.stl` – ready to slice

## Defaults

| parameter       | value  | meaning                                   |
| --------------- | ------ | ----------------------------------------- |
| `inner_height`  | 50 mm  | rim height at the inner (thumb/OLED) edge |
| `lip`           | 4 mm   | wall above the plate's resting plane      |
| `wall`          | 2.5 mm | wall thickness                            |
| `clearance`     | 0.4 mm | gap between case and pocket wall          |
| `ledge_w`       | 2.5 mm | ledge width, inward from the pocket wall  |
| `ledge_t`       | 3 mm   | ledge thickness                           |
| `chamfer_angle` | 55°    | slope of the ledge underside              |

Resulting tent angle is about 15°. Outer rim is 7 mm tall.
Footprint per half: roughly 167 × 120 mm. About 40 cm³ of plastic per half.

Keep `ledge_w` at 3 mm or less: the case screw nearest the edge (top inner
corner) is 5.3 mm in, and its head must clear the ledge. If your bottom plate
has rubber feet near the edge, check those too.

`side = "right"` is the DXF as drawn (inner edge on -X, seen from above);
`side = "left"` mirrors it. If the halves come out swapped, just swap the files.

## Rebuild

```bash
./build.sh
```

Needs OpenSCAD on the PATH (`brew install --cask openscad@snapshot`) and the
experimental `roof()` feature, which `build.sh` enables with `--enable=roof`.
In the GUI, turn on "roof" under Preferences > Features.

## Printing

Print upright, as modelled. The ledge underside slopes at 49–59° from
horizontal after the tilt, so no supports are needed.
