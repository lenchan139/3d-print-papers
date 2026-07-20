// ROBI3-W002-00-09  电动夹 (electric gripper finger)
// Material: AL6061  | Scale: 1:1 | Drawing wt 0.029 kg
// Reconstructed from the blueprint PDF (vector + dimensions).
// Confirmed overall: 100 (Y) x 32 (X) x 20 (Z thickness) mm.
// Geometry basis (front view = extrusion profile, extruded 20 mm in Z):
//   - 4-R2 fillets, R32 jaw arc (center off the upper-right corner)
//   - 8 mm wide mounting tab offset 24 mm from left edge, 17 mm tall
//   - mid full-width block 32 x 21; upper body 24 x 62 with R32 jaw cut
// NOTE: a few hole X/Y positions are inferred from witness/centre lines and
//       should be verified against the drawing.

$fa = 1; $fs = 0.4;

// ---- confirmed dimensions -------------------------------------------------
L      = 100;   // overall length / height (Y)
W      = 32;    // overall width (X)
T      = 20;    // thickness (Z)
body_w = 24;    // body width
tab_w  = 8;     // mounting tab width   (W - body_w)
tab_h  = 17;    // mounting tab protrusion (below body)
mid_h  = 21;    // full-width block height (tab top -> jaw body bottom)
jaw_h  = 62;    // upper body height (= L - tab_h - mid_h)
R32    = 32;    // jaw radius
R2     = 2;     // corner fillets
// R32 arc centre in the (X 0..32, Y 0..100) front face, mm:
jaw_cx = 41.95;
jaw_cy = 69.99;

// ---- hole features (Ø mm, positions inferred; verify) ---------------------
d_45   = 4.50;  // 2x thru, 12 mm spacing, Ø8.6 x 90° countersink
d_cs   = 8.60;
d_m6   = 5.0;   // M6-6H tapped minor Ø approx (thru)
d_5    = 5.0;   // 5 thru
d_3    = 3.0;   // 2x thru
d_34   = 3.40;  // blind deep 8
d_34_d = 8;
d_74   = 7.40;  // hole / counterbore related (verify)

module profile() {
  // upper body: body_w x jaw_h, R2 filleted top corners, minus R32 jaw bite
  translate([0, tab_h + mid_h])
    difference() {
      frect(body_w, jaw_h, R2, true, true, false, false); // fillet TL & TR only
      translate([jaw_cx - 0, jaw_cy - (tab_h + mid_h)]) circle(R32);
    }
  // mid full-width block: W x mid_h, sharp outer corners (step fillets handled visually)
  translate([0, tab_h]) square([W, mid_h]);
  // mounting tab: tab_w x tab_h, R2 at all corners
  translate([body_w, 0]) frect(tab_w, tab_h, R2, true, true, true, true);
}

// filleted rectangle w x h, origin at (0,0). TL TR BL BR flags select corners.
module frect(w, h, r, fTL=true, fTR=true, fBL=true, fBR=true) {
  hull() {
    if (fBL) translate([r,   r])   circle(r); else translate([0,0])     square(0.001,center=true);
    if (fBR) translate([w-r, r])  circle(r); else translate([w,0])     square(0.001,center=true);
    if (fTL) translate([r,   h-r]) circle(r); else translate([0,h])    square(0.001,center=true);
    if (fTR) translate([w-r, h-r]) circle(r); else translate([w,h])    square(0.001,center=true);
  }
}

module countersink(d_thru, d_head, h) {
  // thru hole
  translate([0,0,-0.01]) cylinder(h=h+0.02, d=d_thru);
  // 90° included countersink sunk into the top (Z=h) face: radius head_r at face -> 0 at depth head_r
  r = d_head/2;
  translate([0,0, h - r]) cylinder(h=r+0.02, r1=0, r2=r);
}

module thru(d, h) translate([0,0,-0.01]) cylinder(h=h+0.02, d=d);
module blind(d, depth, h) translate([0,0,h-depth]) cylinder(h=depth+0.01, d=d);

module holes() {
  // 2x Ø4.5 thru + Ø8.6x90° countersink, 12 mm spacing, near jaw tip (top)
  for (x = [12 - 6, 12 + 6])
    translate([x, 92, 0]) countersink(d_45, d_cs, T);
  // M6-6H tapped thru (modelled at minor Ø)
  translate([12, 70, 0]) thru(d_m6, T);
  // Ø5 thru
  translate([12, 85, 0]) thru(d_5, T);
  // 2x Ø3 thru near the R2 step
  translate([20, 44, 0]) thru(d_3, T);
  translate([12, 30, 0]) thru(d_3, T);
  // Ø3.4 blind 8 mm deep (from face Z=0)
  translate([12, 12, 0]) blind(d_34, d_34_d, T);
  // Ø7.4 related (verify) — represented as a clearance thru
  translate([28, 24, 0]) thru(d_74, T);
}

module robi3_w002_00_09() {
  difference() {
    linear_extrude(T) profile();
    holes();
  }
}

robi3_w002_00_09();