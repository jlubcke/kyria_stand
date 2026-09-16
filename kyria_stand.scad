// Tenting tray for a splitkb Kyria rev3 half.
//
// An open shell: perimeter wall + sloped floor, no bottom. The keyboard case
// drops into the pocket and rests on the floor. The inner (thumb/OLED) edge
// is raised so each half is tented outward.
//
// Render:  openscad -o kyria_stand_right.stl -D 'side="right"' kyria_stand.scad
//          openscad -o kyria_stand_left.stl  -D 'side="left"'  kyria_stand.scad
// or just run ./build.sh

// ---------- Parameters ----------------------------------------------------

// Which half. The DXF as drawn has the inner edge on -X; that is the right
// half seen from above. "left" mirrors the whole model.
side = "right"; // ["left", "right"]

inner_height = 50;   // total height of the rim at the inner edge (mm)
lip          = 4;    // how far the wall rises above the floor top (mm)
wall         = 2.5;  // perimeter wall thickness (mm)
floor_t      = 2.5;  // floor plate thickness, measured vertically (mm)
clearance    = 0.4;  // gap between case outline and pocket wall, per side (mm)
outer_gap    = 0;    // extra lift of the floor at the outer edge (mm), 0 = floor underside touches the desk

dxf = "Kyria rev3 Bottom Plate - No Kerf.dxf";

// Outline extents of the DXF (mm), used only to derive the tilt.
x_inner = -74.91;    // inner edge (OLED step + thumb cluster side)
x_outer =  85.89;    // outer edge (pinky side)

$fn = 96;

// ---------- Derived -------------------------------------------------------

// The rim reaches inner_height at the outer face of the inner wall, and the
// floor underside touches the desk at the outer edge of the pocket.
x_lo = x_inner - clearance - wall;   // outer face of the inner wall
x_hi = x_outer + clearance;          // pocket edge on the outer side
z_floor_outer = floor_t + outer_gap;
z_floor_inner = inner_height - lip;
slope = (z_floor_inner - z_floor_outer) / (x_hi - x_lo);   // dz per -dx
tent_deg = atan(slope);

// Floor-top plane: z(x) = c_floor - slope * x
c_floor = z_floor_outer + slope * x_hi;

echo(str("tent angle = ", tent_deg, " deg"));
echo(str("outer rim height = ", z_floor_outer + lip, " mm, inner rim height = ", inner_height, " mm"));

BIG = 1000;

// ---------- 2D profiles ---------------------------------------------------

// Case outline with the M2 holes filled in (grow then shrink closes r=1.2 holes).
module plate_outline() {
    offset(delta = -2) offset(delta = 2) import(dxf);
}

module pocket_profile() { offset(r = clearance) plate_outline(); }
module outer_profile()  { offset(r = clearance + wall) plate_outline(); }

// ---------- Tilted half-spaces --------------------------------------------

// Shear so that a horizontal plane z = c becomes z = c - slope * x.
module tilted() {
    multmatrix([[1, 0, 0, 0],
                [0, 1, 0, 0],
                [-slope, 0, 1, 0],
                [0, 0, 0, 1]]) children();
}

// Everything below the plane z(x) = c - slope * x
module below(c) {
    tilted() translate([-BIG / 2, -BIG / 2, c - BIG]) cube([BIG, BIG, BIG]);
}

// Everything above the plane z(x) = c - slope * x
module above(c) {
    tilted() translate([-BIG / 2, -BIG / 2, c]) cube([BIG, BIG, BIG]);
}

module prism(h = BIG) { linear_extrude(h) children(); }

// ---------- Solid ---------------------------------------------------------

module stand() {
    difference() {
        // Outer body: wall footprint, from the desk up to the rim plane.
        intersection() {
            prism() outer_profile();
            below(c_floor + lip);
        }
        // Pocket: the case sits here, above the floor.
        intersection() {
            prism() pocket_profile();
            above(c_floor);
        }
        // Hollow under the floor (no bottom).
        intersection() {
            translate([0, 0, -1]) prism() pocket_profile();
            below(c_floor - floor_t);
        }
    }
}

if (side == "left") mirror([1, 0, 0]) stand();
else stand();
