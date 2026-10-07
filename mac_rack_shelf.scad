// =====================================================================
//  10" rack cradle: 1x Mac Studio + 2x Mac mini (M1 now, M4 later)
//  5U, open front, 3D-printable. Two ways to build it:
//    * one piece  - the whole frame in a single print, face-down on a
//                   256 x 256 mm bed, no supports, no screws
//    * bolted     - five smaller parts joined with M3 screws (235 mm bed)
//
//  Layout (front view):
//
//      |<-------------- 210.75 mm between side plates -------------->|
//      | |  Mac Studio    | |  mini  | |  mini  | |   spare / gap    |
//      |S|  on its side   |S|        |S|        |S|                  |
//      | |  (96.4 mm bay) | |        | |        | |                  |
//      +=+================+=+========+=+========+=+==================+
//       1                 2        3   4     5    6     (separator slots)
//
//  Separators drop into numbered slots, so the same frame takes
//  M1 minis (36 mm thick), M4 minis (50 mm), or a mix. Every Mac has a
//  separator on its left, and each separator has small doorstops on its
//  right-hand side that hook around the front (and back) edge of that Mac.
//
//  Coordinates (assembled):  X = left/right (0 = rack centre),
//  Y = depth (0 = back face of the rack ears, + towards the rear),
//  Z = up (0 = bottom of the frame).
//
//  Render one part:   openscad -D 'part="frame_onepiece"' -o frame.stl mac_rack_shelf.scad
//  Parts: assembly | frame_onepiece | separator_studio_m1 | separator_m4
//         side_frame_left | side_frame_right | floor | top_bar   (bolted build)
// =====================================================================

/* [View] */
part   = "assembly";  // [assembly, frame_onepiece, separator_studio_m1, separator_m4, side_frame_left, side_frame_right, floor, top_bar]
// Frame shown in the assembly preview
build  = "onepiece";  // [onepiece, bolted]
// Preset separator layout used by the assembly preview
config = "m1";        // [m1, m4, m1_m4, m4_m1, studio_only]
show_devices = true;
explode = 0;          // [0:5:60] pulls the bolted parts apart

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
frame_border = 12;   // width of the outer frame members
bottom_band = 22;    // solid band along the floor joint
lat_pitch   = 44;    // diamond lattice: centre spacing
lat_strut   = 8;     // diamond lattice: strut width (45 deg, prints face-down or flat)
onepiece_overlap = 0.5;  // floor/top bar sink this far into the side plates

/* [Floor] */
floor_t     = 10;
lip_h       = 4;    // front lip that stops devices sliding out
lip_t       = 4;
rear_lip_h  = 4;
rear_lip_t  = 3.5;  // bolted floor only; the one-piece floor uses a 45 deg ramp

/* [Separator slots] */
// presets: only the 6 slots the M1/M4 layouts use (thick floor between them)
// grid:    a slot every slot_pitch mm, for odd-sized devices (1.6 mm walls between slots)
slot_mode   = "presets";   // [presets, grid]
slot_pitch  = 5;
slot_w      = 3.4;
m1_play     = 1;     // side-to-side play in an M1 bay (37 mm bay)
m4_play     = 2;     // side-to-side play in an M4 bay (52 mm bay)
slot_rows   = [[8, 38], [155, 185]];   // Y ranges of the two slot rows (cut through the floor)
studio_play = 1.4;   // side-to-side play in the Studio bay; sets where slot 2 sits
slot_wall   = 1.2;   // floor left between slot 1 and the left side plate

/* [Floor vents] */
floor_vents      = true;
vent_pitch       = 22;   // diamond centre spacing
vent_strut       = 5;    // rib width between diamonds (45 deg, prints without supports)
vent_side_margin = 16;   // solid floor kept along each side plate
vent_row_margin  = 5;    // solid floor kept next to each slot row
vent_spine       = 10;   // solid left-to-right band across the middle of the vents (0 = none)

/* [Separators] */
sep_t       = 3;
sep_h       = 90;    // height above the floor
tab_clear   = 0.3;   // per end, along Y
tab_depth   = 9.5;   // tabs reach 0.5 mm short of the floor's underside

/* [Doorstops] */
// Each separator holds the Mac on its right: a doorstop in front of it and
// one behind it. They print flat with the separator, pointing up.
doorstop_reach = 7;          // how far a doorstop reaches across the Mac's front/back
doorstop_t     = 3;          // doorstop thickness, front to back
doorstop_z     = [16, 70];   // height of the front doorstop and the Studio/M1 rear one
m4_rear_z      = [56, 94];   // the M4 rear doorstop sits high so the separator lifts out over an M4
doorstop_rear  = true;       // false: front doorstops only, so any Mac slides out on its own
dev_front      = -1;         // front face of the Macs (back of the floor's front lip)
dev_play_y     = 1;          // front-to-back play between the doorstops

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

// Slot 1 sits against the left side plate, on the Studio's left. Slot 2 is
// the Studio's right-hand separator. The rest sit where a separator lands
// after one or two minis (M1 or M4), unless its doorstops would hit the
// right side plate. The floor under the Studio has no slots.
slot_x1 = -xi + slot_w / 2 + slot_wall;
slot_x0 = slot_x1 + sep_t + studio_dim[2] + studio_play;

function bay_w(kind) = kind == "m4" ? m4_dim[2] + m4_play : m1_dim[2] + m1_play;
function slot_fits(x) = x + sep_t / 2 + doorstop_reach + 0.5 <= xi;
// Separator positions from the Studio's right-hand separator onward, for a
// list of minis left to right. The last one is left out when the final
// mini simply sits against the side plate.
function mini_xs(devs, i = 0, x = slot_x0) =
    i < len(devs)
        ? concat([x], mini_xs(devs, i + 1, x + sep_t + bay_w(devs[i])))
        : (slot_fits(x) ? [x] : []);

function qsort(v) = len(v) <= 1 ? v : let(p = v[0])
    concat(qsort([for (x = v) if (x < p) x]), [for (x = v) if (x == p) x], qsort([for (x = v) if (x > p) x]));
function dedupe(v) = [for (i = [0 : len(v) - 1]) if (i == 0 || v[i] - v[i - 1] > 0.01) v[i]];

combos = [["m1"], ["m4"], ["m1", "m1"], ["m1", "m4"], ["m4", "m1"], ["m4", "m4"]];
slot_xs = slot_mode == "grid"
    ? concat([slot_x1], [for (x = [slot_x0 : slot_pitch : xi]) if (slot_fits(x)) x])
    : concat([slot_x1], dedupe(qsort([for (c = combos) each mini_xs(c)])));
slot_count = len(slot_xs);                     // 6 in preset mode
function slot_x(n) = slot_xs[n - 1];
// slot number (1 = far left) of a separator position
function slot_no(x) = [for (i = [0 : slot_count - 1]) if (abs(slot_xs[i] - x) < 0.01) i + 1][0];

// Minis that fill the bays to the right of the Studio, left to right
function preset_devices(c) =
    c == "m1"    ? ["m1", "m1"] :
    c == "m4"    ? ["m4", "m4"] :
    c == "m1_m4" ? ["m1", "m4"] :
    c == "m4_m1" ? ["m4", "m1"] :
                   [];

// Separator positions for a preset: left of the Studio, right of the Studio,
// then one after each mini that needs it.
function preset_xs(c) = concat([slot_x1], mini_xs(preset_devices(c)));

function dev_depth(kind) = kind == "m4" ? m4_dim[1] : kind == "m1" ? m1_dim[1] : studio_dim[1];
// Depth of the Mac held by separator k of a preset (the Mac on its right).
// A separator with nothing on its right gets the long doorstops.
function sep_hold(c, k) = let(d = preset_devices(c))
    k == 0 ? studio_dim[1] : (k - 1 < len(d) ? dev_depth(d[k - 1]) : studio_dim[1]);

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

// Diamond lattice: every edge is at 45 deg, so the plate prints without
// supports lying flat (bolted build) or standing on its front edge (one piece).
// Only whole diamonds are cut, so no window ends in a flat ceiling.
module side_windows() {
    off_v = frame_border * sqrt(1 + pow((panel_h - h_rear) / (y_back - col_d), 2));
    h  = lat_pitch / 2 - lat_strut / sqrt(2);      // half-diagonal of a window
    r  = 2.5;
    y0 = col_d + h + 1;
    z0 = bottom_band + h + 1;
    n  = ceil(2 * panel_h / lat_pitch);
    for (i = [0 : n], j = [0 : n]) if ((i + j) % 2 == 0) {
        cy = y0 + i * lat_pitch / 2;
        cz = z0 + j * lat_pitch / 2;
        if (cy + h <= y_back - frame_border && cz + h <= top_z(cy) - off_v)
            translate([cy, cz]) offset(r = r) offset(delta = -r)
                rotate(45) square(h * sqrt(2), center = true);
    }
}

module side_frame_right(bolts = true) {
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
        if (bolts) {
            // floor bolts (countersunk from the outside)
            for (y = floor_bolt_y) translate([xo, y, floor_bolt_z]) mirror([1, 0, 0]) csk_hole(side_t + 1);
            // top bar bolts
            translate([xo, bar_bolt_y, bar_bolt_z]) mirror([1, 0, 0]) csk_hole(side_t + 1);
        }
        // soften the outer corners of the ear
        for (z = [0, panel_h]) translate([panel_w / 2, y_front - 1, z])
            rotate([-90, 0, 0]) cylinder(r = 3, h = ear_t + 2, $fn = 4);
    }
}

module side_frame_left(bolts = true) { mirror([1, 0, 0]) side_frame_right(bolts); }

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

// bolts: side bolt holes + nut traps (bolted build)
// ramp:  45 deg rear stop instead of a square lip (one piece, printed face-down)
// ov:    extra width on each side so the floor fuses into the side plates
// Diamond vents between the two slot rows. Whole diamonds only, with 45 deg
// edges, so they print without supports flat (bolted floor) or standing
// up (one-piece frame printed face-down).
module floor_vent_holes() {
    y_lo  = slot_rows[0][1] + vent_row_margin;
    y_hi  = slot_rows[1][0] - vent_row_margin;
    y_mid = (y_lo + y_hi) / 2;
    fields = vent_spine > 0
        ? [[y_lo, y_mid - vent_spine / 2], [y_mid + vent_spine / 2, y_hi]]
        : [[y_lo, y_hi]];
    for (f = fields) vent_field(f[0], f[1]);
}

module vent_field(y_lo, y_hi) {
    h     = vent_pitch / 2 - vent_strut / sqrt(2);   // half-diagonal
    x_lim = xi - vent_side_margin;
    step  = vent_pitch / 2;
    m     = floor((y_hi - y_lo - 2 * h) / step);
    y0    = (y_lo + y_hi) / 2 - m * step / 2;
    nx    = ceil(x_lim / step);
    for (i = [-nx : nx], j = [0 : m]) if ((i + j + 2 * nx) % 2 == 0) {
        cx = i * step;
        cy = y0 + j * step;
        if (abs(cx) + h <= x_lim)
            translate([cx, cy, -1]) linear_extrude(floor_t + 2)
                offset(r = 1.5) offset(delta = -1.5) rotate(45) square(h * sqrt(2), center = true);
    }
}

module floor_part(bolts = true, ramp = false, ov = 0) {
    w = inner_w + 2 * ov;
    difference() {
        union() {
            translate([-xi - ov, y_front, 0]) cube([w, y_back - y_front, floor_t]);
            translate([-xi - ov, y_front, floor_t - eps]) cube([w, lip_t, lip_h + eps]);
            if (ramp)
                translate([-xi - ov, 0, 0]) rotate([90, 0, 90]) linear_extrude(w)
                    polygon([[y_back - rear_lip_h, floor_t - eps], [y_back, floor_t - eps], [y_back, floor_t + rear_lip_h]]);
            else
                translate([-xi - ov, y_back - rear_lip_t, floor_t - eps]) cube([w, rear_lip_t, rear_lip_h + eps]);
        }
        // separator slots, cut all the way through the floor
        for (x = slot_xs, r = slot_rows)
            translate([x - slot_w / 2, r[0], -1])
                cube([slot_w, r[1] - r[0], floor_t + 2]);
        if (floor_vents) floor_vent_holes();
        // side bolts + nut traps
        if (bolts) for (s = [-1, 1], y = floor_bolt_y) {
            translate([s * xi, y, floor_bolt_z]) mirror([s > 0 ? 1 : 0, 0, 0]) bolt_hole(nut_inset + 6);
            translate([s * (xi - nut_inset), y, 0]) nut_slot_from_top(floor_bolt_z, floor_t);
        }
    }
}

// ---------------------------------------------------------------------
// Top bar (ties the two side frames together at the top front)
// ---------------------------------------------------------------------
module top_bar(bolts = true, ov = 0) {
    z0 = panel_h - bar_h;
    difference() {
        translate([-xi - ov, y_front, z0]) cube([inner_w + 2 * ov, bar_d, bar_h]);
        // chamfer the front-bottom edge
        translate([0, y_front, z0]) rotate([45, 0, 0]) cube([inner_w + 2 * ov + 2, 2.5, 2.5], center = true);
        if (bolts) for (s = [-1, 1]) {
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
// One-piece frame: side frames, floor and top bar fused, no hardware.
// Print it face-down (rack ears on the bed): every overhang is 45 deg or
// less, and the top bar sits on the bed instead of bridging 210 mm.
// ---------------------------------------------------------------------
module frame_onepiece() {
    union() {
        side_frame_right(bolts = false);
        side_frame_left(bolts = false);
        floor_part(bolts = false, ramp = true, ov = onepiece_overlap);
        top_bar(bolts = false, ov = onepiece_overlap);
    }
}

// ---------------------------------------------------------------------
// Separator (assembled at x = 0; place with translate([slot_x(n),0,0]))
// ---------------------------------------------------------------------
sep_y0 = -0.5;
sep_y1 = y_back - max(rear_lip_t, rear_lip_h) - 0.5;

function rear_stop_y(depth) = dev_front + depth + dev_play_y;   // inner face of the rear doorstop
function rear_is_mid(depth) = rear_stop_y(depth) + doorstop_t < sep_y1 - 12;
function rear_z(depth) = rear_is_mid(depth) ? m4_rear_z : doorstop_z;

module separator_body(body_h) {
    translate([sep_y0, floor_t]) hull() {
        square([1, 1]);
        translate([sep_y1 - sep_y0 - 1, 0]) square([1, 1]);
        translate([28, body_h - 28]) circle(r = 28);
        translate([sep_y1 - sep_y0 - 8, body_h - 8]) circle(r = 8);
    }
}

// hold: depth of the Mac on the separator's right (197 Studio/M1, 127 M4)
module separator_profile(hold) {   // 2D in (Y, Z)
    yr = rear_stop_y(hold);
    rz = rear_z(hold);
    difference() {
        union() {
            separator_body(sep_h);
            // tabs, chamfered at the bottom for easy insertion
            for (r = slot_rows) {
                a = r[0] + tab_clear;
                b = r[1] - tab_clear;
                c = 1.2;
                polygon([[a, floor_t + eps], [a, floor_t - tab_depth + c], [a + c, floor_t - tab_depth],
                         [b - c, floor_t - tab_depth], [b, floor_t - tab_depth + c], [b, floor_t + eps]]);
            }
            // plate reaches forward to carry the front doorstop
            translate([dev_front - doorstop_t, doorstop_z[0]])
                square([sep_y0 + 1 - dev_front + doorstop_t, doorstop_z[1] - doorstop_z[0]]);
            // ...and back to carry a rear doorstop that sits past the plate
            if (doorstop_rear && !rear_is_mid(hold))
                translate([sep_y1 - 1, rz[0]]) square([yr + doorstop_t - sep_y1 + 1, rz[1] - rz[0]]);
        }
        // vent / grip windows; one strut always lands under the M4 rear doorstop
        struts = [67, rear_stop_y(m4_dim[1]) + doorstop_t / 2];
        offset(r = 5) offset(delta = -5)
        difference() {
            intersection() {
                offset(delta = -11) separator_body(sep_h);
                translate([-100, floor_t + 12]) square([1000, 1000]);
            }
            for (y = struts) translate([y - 4, 0]) square([8, 1000]);
            if (rear_is_mid(hold)) translate([yr + doorstop_t / 2 - 4, 0]) square([8, 1000]);
        }
    }
}

// Doorstop on the separator's right face, covering y in [y_a, y_a + doorstop_t]
module doorstop(y_a, z_range) {
    c = min(3, doorstop_reach / 2);
    r = doorstop_reach;
    translate([sep_t / 2 - eps, y_a + doorstop_t, 0]) rotate([90, 0, 0])
        linear_extrude(doorstop_t)
            polygon([[0, z_range[0]], [r - c, z_range[0]], [r, z_range[0] + c],
                     [r, z_range[1] - c], [r - c, z_range[1]], [0, z_range[1]]]);
}

module separator(hold = 197) {
    rotate([90, 0, 90]) linear_extrude(sep_t, center = true) separator_profile(hold);
    doorstop(dev_front - doorstop_t, doorstop_z);
    if (doorstop_rear) doorstop(rear_stop_y(hold), rear_z(hold));
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
    seps = preset_xs(config);
    devs = preset_devices(config);
    e = build == "bolted" ? explode : 0;
    if (build == "bolted") {
        color(c_frame) translate([e, 0, 0]) side_frame_right();
        color(c_frame) translate([-e, 0, 0]) side_frame_left();
        color(c_floor) translate([0, 0, -e]) floor_part();
        color(c_frame) translate([0, 0, e]) top_bar();
    } else {
        color(c_frame) frame_onepiece();
    }
    color(c_sep) for (k = [0 : len(seps) - 1])
        translate([seps[k], 0, e / 2]) separator(sep_hold(config, k));
    if (show_devices) translate([0, -2 * e, 0]) {
        studio_dummy((seps[0] + seps[1] - studio_dim[2]) / 2);
        if (len(devs) > 0) for (i = [0 : len(devs) - 1]) {
            bay_l = seps[i + 1] + sep_t / 2;
            bay_r = (i + 2 < len(seps)) ? seps[i + 2] - sep_t / 2 : xi;
            w = devs[i] == "m4" ? m4_dim[2] : m1_dim[2];
            mini_dummy(devs[i], (bay_l + bay_r - w) / 2);
        }
    }
}

// ---------------------------------------------------------------------
// Print orientations
// ---------------------------------------------------------------------
module print_frame_onepiece() {       // face-down: rack ears and front edges on the bed
    translate([0, panel_h / 2, -y_front]) rotate([90, 0, 0]) frame_onepiece();
}
module print_side_frame_right() {     // inner face on the bed
    rotate([0, -90, 0]) translate([-xi, 0, 0]) side_frame_right();
}
module print_side_frame_left() {
    rotate([0, 90, 0]) translate([xi, 0, 0]) side_frame_left();
}
module print_top_bar() {
    translate([0, 0, -(panel_h - bar_h)]) top_bar();
}
module print_separator(hold) {         // lying flat on its left face, doorstops up
    rotate([0, -90, 0]) translate([sep_t / 2, 0, 0]) separator(hold);
}

if (part == "assembly")              assembly();
else if (part == "frame_onepiece")   print_frame_onepiece();
else if (part == "side_frame_right") print_side_frame_right();
else if (part == "side_frame_left")  print_side_frame_left();
else if (part == "floor")            floor_part();
else if (part == "top_bar")          print_top_bar();
else if (part == "separator_studio_m1") print_separator(studio_dim[1]);
else if (part == "separator_m4")     print_separator(m4_dim[1]);

// Echo the useful numbers when rendering
echo(str("inner width = ", inner_w, " mm, ", slot_count, " slots at x = ", slot_xs,
         ", Studio bay = ", slot_x(2) - slot_x(1) - sep_t, " mm"));
for (c = ["m1", "m4", "m1_m4", "m4_m1"])
    echo(str("preset ", c, ": slots ", [for (x = preset_xs(c)) slot_no(x)]));
