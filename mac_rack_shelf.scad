// =====================================================================
//  10" rack cradle: 1x Mac Studio + 2x Mac mini (M1 now, M4 later)
//  5U, open front, bolt-together, 3D-printable on a 256 mm bed.
//
//  Layout (front view):
//
//      |<-------------- 210.75 mm between side plates -------------->|
//      |  Mac Studio      | |  mini  | |  mini  | |   spare / gap    |
//      |  on its side     |S|        |S|        |S|                  |
//      |  (97 mm bay)     | |        | |        | |                  |
//      +==================+=+========+=+========+=+==================+
//                       floor with 42 separator slots (5 mm pitch)
//
//  Separators drop into numbered slots, so the same frame takes
//  M1 minis (36 mm thick), M4 minis (50 mm), or a mix.
//
//  Coordinates (assembled):  X = left/right (0 = rack centre),
//  Y = depth (0 = back face of the rack ears, + towards the rear),
//  Z = up (0 = bottom of the frame).
//
//  Render one part:   openscad -D 'part="floor"' -o floor.stl mac_rack_shelf.scad
//  Parts: assembly | side_frame_left | side_frame_right | floor | top_bar | separator
// =====================================================================

/* [View] */
part   = "assembly";  // [assembly, side_frame_left, side_frame_right, floor, top_bar, separator]
// Preset separator layout used by the assembly preview
config = "m1";        // [m1, m4, m1_m4, m4_m1, studio_only]
show_devices = true;
explode = 0;          // [0:5:60]

/* [Rack] */
U              = 44.45;
rack_units     = 5;
panel_w        = 254;     // 10" panel width
rack_opening   = 222.25;  // clear width between the rails (8.75")
rail_hole_pitch = 236.5;  // centre-to-centre of rail holes (racks vary 235-237)
side_clear     = 0.75;    // gap between side plate and rail, per side
ear_slot_d     = 6.6;     // fits M6 / M5 / 10-32 rack screws
ear_slot_len   = 10;      // horizontal slot, absorbs 235-237 mm hole pitch

/* [Devices] */
studio_dim = [197, 197, 95];   // W, D, H lying flat (Apple spec)
m1_dim     = [197, 197, 36];
m4_dim     = [127, 127, 50];

/* [Frame] */
side_t      = 5;     // side plate thickness
ear_t       = 5;     // rack ear thickness
depth       = 201.5; // frame depth behind the ears
h_rear      = 60;    // side-frame height at the rear
col_d       = 25;    // full-height solid column behind the ear
frame_border = 12;   // truss member width
bottom_band = 22;    // solid band carrying the floor bolts

/* [Floor] */
floor_t     = 10;
lip_h       = 4;    // front lip that stops devices sliding out
lip_t       = 4;
rear_lip_h  = 4;
rear_lip_t  = 3.5;

/* [Separator slots] */
slot_pitch  = 5;
slot_w      = 3.4;
slot_depth  = 5;
slot_rows   = [[8, 38], [155, 185]];   // Y ranges of the two slot rows

/* [Separators] */
sep_t       = 3;
sep_h       = 90;    // height above the floor
tab_clear   = 0.3;   // per end, along Y
tab_depth   = 4.7;

/* [Top bar] */
bar_h       = 8;
bar_d       = 12;

/* [Hardware: M3 countersunk + hex nut] */
bolt_d      = 3.4;
csk_d       = 6.6;
nut_af      = 5.5;   // across flats
nut_t       = 2.4;
nut_clear   = 0.3;
floor_bolt_y = [46, 100, 147, 195];
floor_bolt_z = 5;
nut_inset   = 7;     // nut centre distance from the floor/bar end face

$fn = 48;
eps = 0.01;

// ---------------------------------------------------------------------
// Derived dimensions
// ---------------------------------------------------------------------
panel_h  = rack_units * U - 0.8;            // 221.45 for 5U
frame_w  = rack_opening - 2 * side_clear;   // outside of side plates
inner_w  = frame_w - 2 * side_t;            // between side plates
xi       = inner_w / 2;                      // inner face of right plate
xo       = frame_w / 2;                      // outer face of right plate
y_front  = -ear_t;
y_back   = depth;
bar_bolt_y = y_front + bar_d / 2;
bar_bolt_z = panel_h - bar_h / 2;

// Slots sit on odd multiples of pitch/2 so the grid is symmetric and the
// Studio bay works on either side.
slot_half  = floor((xi - slot_w / 2 - 1) / slot_pitch + 0.5);
slot_count = 2 * slot_half;                  // 42 with the defaults
function slot_x(n) = (n - (slot_count + 1) / 2) * slot_pitch;

// Separator slot numbers (1 = far left) for each preset
function preset(c) =
    c == "m1"    ? [20, 28, 36] :
    c == "m4"    ? [20, 31, 42] :
    c == "m1_m4" ? [20, 28, 39] :
    c == "m4_m1" ? [20, 31, 39] :
                   [20];

// Devices that fill the bays left to right
function preset_devices(c) =
    c == "m1"    ? ["m1", "m1"] :
    c == "m4"    ? ["m4", "m4"] :
    c == "m1_m4" ? ["m1", "m4"] :
    c == "m4_m1" ? ["m4", "m1"] :
                   [];

// ---------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------
module rounded_rect(size, r) {
    offset(r = r) offset(delta = -r) square(size);
}

// Countersunk M3 hole along +X, head at x = 0 facing -X
module csk_hole(len) {
    rotate([0, 90, 0]) {
        translate([0, 0, -eps]) cylinder(d = bolt_d, h = len + 2 * eps);
        translate([0, 0, -eps]) cylinder(d1 = csk_d, d2 = bolt_d, h = (csk_d - bolt_d) / 2 + eps);
    }
}

// Plain M3 hole along +X
module bolt_hole(len) {
    rotate([0, 90, 0]) translate([0, 0, -eps]) cylinder(d = bolt_d, h = len + 2 * eps);
}

// ---------------------------------------------------------------------
// Side frame (right-hand, assembled position).  Left = mirror.
// ---------------------------------------------------------------------
function top_z(y) = panel_h - (y - col_d) * (panel_h - h_rear) / (y_back - col_d);

module side_outline() {
    polygon([[y_front, 0], [y_back, 0], [y_back, h_rear],
             [col_d, panel_h], [y_front, panel_h]]);
}

module side_windows() {
    win_r   = 6;
    strut_w = 9;
    z0      = bottom_band;
    // vertical struts and the y-ranges of the panels between them
    vy  = [col_d + 50, col_d + 112];
    pys = [col_d, vy[0], vy[1], y_back];
    off_v = frame_border * sqrt(1 + pow((panel_h - h_rear) / (y_back - col_d), 2));
    offset(r = win_r) offset(delta = -win_r)
    difference() {
        intersection() {
            offset(delta = -frame_border) side_outline();
            translate([col_d, z0]) square([1000, 1000]);
        }
        for (y = vy) translate([y - strut_w / 2, -1]) square([strut_w, 1000]);
        // one tension diagonal per panel: bottom-rear to top-front
        for (i = [0 : len(pys) - 2]) {
            ya = pys[i];
            yb = pys[i + 1];
            hull() {
                translate([yb, z0]) circle(d = strut_w);
                translate([ya, top_z(ya) - off_v]) circle(d = strut_w);
            }
        }
    }
}

module side_frame_right() {
    difference() {
        union() {
            // side plate (YZ profile extruded along X)
            translate([xi, 0, 0]) rotate([90, 0, 90])
                linear_extrude(side_t) difference() { side_outline(); side_windows(); }
            // rack ear
            translate([xi, y_front, 0]) cube([panel_w / 2 - xi, ear_t, panel_h]);
        }
        // rack slots
        for (u = [0 : rack_units - 1], hz = [6.35, 22.225, 38.1]) {
            z = u * U + hz - 0.4;
            translate([rail_hole_pitch / 2, y_front - 1, z]) rotate([-90, 0, 0])
                linear_extrude(ear_t + 2) hull() {
                    for (s = [-1, 1]) translate([s * (ear_slot_len - ear_slot_d) / 2, 0])
                        circle(d = ear_slot_d);
                }
        }
        // floor bolts (countersunk from the outside)
        for (y = floor_bolt_y) translate([xo, y, floor_bolt_z]) mirror([1, 0, 0]) csk_hole(side_t + 1);
        // top bar bolts
        translate([xo, bar_bolt_y, bar_bolt_z]) mirror([1, 0, 0]) csk_hole(side_t + 1);
        // soften the outer corners of the ear
        for (z = [0, panel_h]) translate([panel_w / 2, y_front - 1, z])
            rotate([-90, 0, 0]) cylinder(r = 3, h = ear_t + 2, $fn = 4);
    }
}

module side_frame_left() { mirror([1, 0, 0]) side_frame_right(); }

// ---------------------------------------------------------------------
// Floor
// ---------------------------------------------------------------------
// Vertical nut slot open to the top, nut axis along X, flats facing +/-Y
module nut_slot_from_top(z_axis, z_top) {
    w  = nut_af + nut_clear;
    t  = nut_t + nut_clear;
    zb = z_axis - (nut_af / sqrt(3)) - nut_clear / 2;   // corner pointing down
    translate([-t / 2, -w / 2, zb]) cube([t, w, z_top - zb + 1]);
}

module floor_part() {
    difference() {
        union() {
            translate([-xi, y_front, 0]) cube([inner_w, y_back - y_front, floor_t]);
            translate([-xi, y_front, floor_t - eps]) cube([inner_w, lip_t, lip_h + eps]);
            translate([-xi, y_back - rear_lip_t, floor_t - eps]) cube([inner_w, rear_lip_t, rear_lip_h + eps]);
        }
        // separator slots
        for (n = [1 : slot_count], r = slot_rows)
            translate([slot_x(n) - slot_w / 2, r[0], floor_t - slot_depth])
                cube([slot_w, r[1] - r[0], slot_depth + 1]);
        // slot numbers, read from the front like a ruler
        for (n = [1 : slot_count])
            translate([slot_x(n), y_front + lip_t + 0.8, floor_t - 0.6])
                linear_extrude(1) rotate(90)
                    text(str(n), size = 3.4, font = "Liberation Sans:style=Bold",
                         halign = "left", valign = "center");
        // side bolts + nut traps
        for (s = [-1, 1], y = floor_bolt_y) {
            translate([s * xi, y, floor_bolt_z]) mirror([s > 0 ? 1 : 0, 0, 0]) bolt_hole(nut_inset + 6);
            translate([s * (xi - nut_inset), y, 0]) nut_slot_from_top(floor_bolt_z, floor_t);
        }
    }
}

// ---------------------------------------------------------------------
// Top bar (ties the two side frames together at the top front)
// ---------------------------------------------------------------------
module top_bar() {
    z0 = panel_h - bar_h;
    difference() {
        translate([-xi, y_front, z0]) cube([inner_w, bar_d, bar_h]);
        // chamfer the front-bottom edge
        translate([0, y_front, z0]) rotate([45, 0, 0]) cube([inner_w + 2, 2.5, 2.5], center = true);
        for (s = [-1, 1]) {
            translate([s * xi, bar_bolt_y, bar_bolt_z]) mirror([s > 0 ? 1 : 0, 0, 0]) bolt_hole(nut_inset + 6);
            // nut slot open to the rear face, flats facing +/-Z
            w = nut_af + nut_clear;
            t = nut_t + nut_clear;
            translate([s * (xi - nut_inset) - t / 2, bar_bolt_y - nut_af / sqrt(3) - nut_clear / 2, bar_bolt_z - w / 2])
                cube([t, bar_d, w]);
        }
    }
}

// ---------------------------------------------------------------------
// Separator (assembled at x = 0; place with translate([slot_x(n),0,0]))
// ---------------------------------------------------------------------
sep_y0 = -0.5;
sep_y1 = y_back - rear_lip_t - 0.5;

module separator_profile() {   // 2D in (Y, Z)
    body_h = sep_h;
    difference() {
        union() {
            // body with a big radius on the top-front corner
            translate([sep_y0, floor_t]) hull() {
                square([1, 1]);
                translate([sep_y1 - sep_y0 - 1, 0]) square([1, 1]);
                translate([28, body_h - 28]) circle(r = 28);
                translate([sep_y1 - sep_y0 - 8, body_h - 8]) circle(r = 8);
            }
            // tabs, chamfered at the bottom for easy insertion
            for (r = slot_rows) {
                a = r[0] + tab_clear;
                b = r[1] - tab_clear;
                c = 1.2;
                polygon([[a, floor_t + eps], [a, floor_t - tab_depth + c], [a + c, floor_t - tab_depth],
                         [b - c, floor_t - tab_depth], [b, floor_t - tab_depth + c], [b, floor_t + eps]]);
            }
        }
        // vent / grip windows
        offset(r = 5) offset(delta = -5)
        difference() {
            intersection() {
                offset(delta = -11) translate([sep_y0, floor_t]) hull() {
                    square([1, 1]);
                    translate([sep_y1 - sep_y0 - 1, 0]) square([1, 1]);
                    translate([28, body_h - 28]) circle(r = 28);
                    translate([sep_y1 - sep_y0 - 8, body_h - 8]) circle(r = 8);
                }
                translate([-100, floor_t + 12]) square([1000, 1000]);
            }
            for (y = [52, 99, 146]) translate([y - 4, 0]) square([8, 1000]);
        }
    }
}

module separator() {
    rotate([90, 0, 90]) linear_extrude(sep_t, center = true) separator_profile();
}

// ---------------------------------------------------------------------
// Reference devices (for the preview only)
// ---------------------------------------------------------------------
module rbox(d, r) {
    hull() for (x = [r, d[0] - r], y = [r, d[1] - r]) translate([x, y, 0]) cylinder(r = r, h = d[2]);
}

// A box device standing on its edge, bottom facing -X, front at y = y_front_dev
module device_on_edge(dim, foot_d, foot_h, x_left) {
    y_dev = sep_y0;
    translate([x_left, y_dev, floor_t])
        translate([0, 0, dim[0]]) rotate([0, 90, 0]) {
            // flat orientation: width along X, depth along Y, height along Z
            translate([0, 0, foot_h]) rbox([dim[0], dim[1], dim[2] - foot_h], 12);
            translate([dim[0] / 2, dim[1] / 2, 0]) cylinder(d = foot_d, h = foot_h + eps, $fn = 96);
        }
}

module studio_dummy(x_left) {
    color("#c9ccd1", 0.95) device_on_edge(studio_dim, 180, 6, x_left);
    // front ports hint
    color("#222") for (i = [0:1]) translate([x_left + 30, sep_y0 - 0.2, floor_t + 150 - i * 14]) cube([8, 0.4, 3]);
}

module mini_dummy(kind, x_left) {
    dim = kind == "m4" ? m4_dim : m1_dim;
    foot = kind == "m4" ? 110 : 160;
    color(kind == "m4" ? "#d8dade" : "#b8bcc2", 0.95) device_on_edge(dim, foot, 2, x_left);
}

// ---------------------------------------------------------------------
// Assembly
// ---------------------------------------------------------------------
c_frame = "#2f3337";
c_floor = "#3b4045";
c_sep   = "#f28c28";

module assembly() {
    seps = preset(config);
    devs = preset_devices(config);
    e = explode;
    color(c_frame) translate([e, 0, 0]) side_frame_right();
    color(c_frame) translate([-e, 0, 0]) side_frame_left();
    color(c_floor) translate([0, 0, -e]) floor_part();
    color(c_frame) translate([0, 0, e]) top_bar();
    color(c_sep) for (n = seps) translate([slot_x(n), 0, e / 2]) separator();
    if (show_devices) translate([0, -2 * e, 0]) {
        studio_dummy(-xi + 0.7);
        if (len(devs) > 0) for (i = [0 : len(devs) - 1]) {
            bay_l = slot_x(seps[i]) + sep_t / 2;
            bay_r = (i + 1 < len(seps)) ? slot_x(seps[i + 1]) - sep_t / 2 : xi;
            w = devs[i] == "m4" ? m4_dim[2] : m1_dim[2];
            mini_dummy(devs[i], (bay_l + bay_r - w) / 2);
        }
    }
}

// ---------------------------------------------------------------------
// Print orientations
// ---------------------------------------------------------------------
module print_side_frame_right() {     // inner face on the bed
    rotate([0, -90, 0]) translate([-xi, 0, 0]) side_frame_right();
}
module print_side_frame_left() {
    rotate([0, 90, 0]) translate([xi, 0, 0]) side_frame_left();
}
module print_top_bar() {
    translate([0, 0, -(panel_h - bar_h)]) top_bar();
}
module print_separator() {             // lying flat
    rotate([0, 90, 0]) translate([-sep_t / 2, 0, 0]) separator();
}

if (part == "assembly")              assembly();
else if (part == "side_frame_right") print_side_frame_right();
else if (part == "side_frame_left")  print_side_frame_left();
else if (part == "floor")            floor_part();
else if (part == "top_bar")          print_top_bar();
else if (part == "separator")        print_separator();

// Echo the useful numbers when rendering
echo(str("inner width = ", inner_w, " mm, slots = ", slot_count,
         ", slot 1 x = ", slot_x(1), ", Studio bay = ", slot_x(20) - sep_t / 2 + xi, " mm"));
