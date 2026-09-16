// Tenting stand for a splitkb Kyria rev3 half.
//
// A perimeter wall following the case outline, with a small inward ledge the
// bottom plate rests on. No floor, no bottom. The ledge has a sloped
// underside so the part prints upright without any support material.
// The inner (thumb/OLED) edge is raised so each half is tented outward.
//
// Needs the experimental roof() feature:
//   openscad --enable=roof -o kyria_stand_right.stl -D 'side="right"' kyria_stand.scad
// or just run ./build.sh. In the GUI enable "roof" under Preferences > Features.

// ---------- Parameters ----------------------------------------------------

// Which half. The DXF as drawn has the inner edge on -X; that is the right
// half seen from above. "left" mirrors the whole model.
side = "right"; // ["left", "right"]

inner_height  = 50;   // total height of the rim at the inner edge (mm)
lip           = 4;    // how far the wall rises above the plate's resting plane (mm)
wall          = 2.5;  // perimeter wall thickness (mm)
clearance     = 0.4;  // gap between case outline and pocket wall, per side (mm)
ledge_w       = 2.5;  // how far the ledge protrudes inward from the pocket wall (mm)
                      // keep <= 3: the nearest case screw is 5.3 mm from the edge
ledge_t       = 3;    // ledge thickness, measured vertically (mm)
chamfer_angle = 55;   // slope of the ledge underside, from horizontal (deg)
outer_gap     = 0;    // extra lift of the ledge at the outer edge (mm), 0 = ledge underside touches the desk

dxf = "Kyria rev3 Bottom Plate - No Kerf.dxf";

// Outline extents of the DXF (mm), used only to derive the tilt.
x_inner = -74.91;    // inner edge (OLED step + thumb cluster side)
x_outer =  85.89;    // outer edge (pinky side)

$fn = 96;

// ---------- Derived -------------------------------------------------------

chamfer_h = ledge_w * tan(chamfer_angle);   // height of the sloped underside

// The rim reaches inner_height at the outer face of the inner wall, and the
// ledge underside touches the desk at the outer edge of the pocket.
x_lo = x_inner - clearance - wall;   // outer face of the inner wall
x_hi = x_outer + clearance;          // pocket edge on the outer side
z_top_outer = ledge_t + outer_gap;
z_top_inner = inner_height - lip;
slope = (z_top_inner - z_top_outer) / (x_hi - x_lo);   // dz per -dx
tent_deg = atan(slope);

// Plate resting plane (ledge top): z(x) = c_top - slope * x
c_top = z_top_outer + slope * x_hi;

echo(str("tent angle = ", tent_deg, " deg"));
echo(str("outer rim height = ", z_top_outer + lip, " mm, inner rim height = ", inner_height, " mm"));
echo(str("ledge underside slope after tilt: ", atan(tan(chamfer_angle) - slope), " to ",
         atan(tan(chamfer_angle) + slope), " deg from horizontal"));

BIG = 1000;

// ---------- 2D profiles ---------------------------------------------------

// Case outline with the M2 holes filled in (grow then shrink closes r=1.2 holes).
module plate_outline() {
    offset(delta = -2) offset(delta = 2) import(dxf);
}

module pocket_profile() { offset(r = clearance) plate_outline(); }
module outer_profile()  { offset(r = clearance + wall) plate_outline(); }
module inside_ledge()   { offset(r = -ledge_w) pocket_profile(); }

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

// Tall prism of a 2D profile, starting just below the desk so cuts go through.
module prism(h = BIG) { translate([0, 0, -1]) linear_extrude(h + 1) children(); }

// ---------- Solid ---------------------------------------------------------

module stand() {
    difference() {
        // Outer body: wall footprint, from the desk up to the rim plane.
        intersection() {
            linear_extrude(BIG) outer_profile();
            below(c_top + lip);
        }
        // Pocket: the case sits here, above the ledge.
        intersection() {
            prism() pocket_profile();
            above(c_top);
        }
        // Open middle, all the way through.
        prism() inside_ledge();
        // Open bottom, below the ledge's sloped underside.
        intersection() {
            prism() pocket_profile();
            below(c_top - ledge_t - chamfer_h);
        }
        // Sloped underside of the ledge: roof() rises at 45 deg from the
        // pocket outline; scaling z sets the chamfer angle. Everything above
        // the ledge's inner edge is already open, so its top needs no clipping.
        tilted() translate([0, 0, c_top - ledge_t - chamfer_h])
            scale([1, 1, chamfer_h / ledge_w])
                roof() pocket_profile();
    }
}

if (side == "left") mirror([1, 0, 0]) stand();
else stand();
