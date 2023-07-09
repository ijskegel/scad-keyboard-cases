include <kle/redox-layout.scad>
include <../keyboard-case.scad>

$fa = 1;
$fs = $preview ? 5 : 2;
bezier_precision = $preview ? 0.05 : 0.025;

// Hacky way to select just the left hand keys from split iris/redox layout
left_keys = [ for (i = redox_layout) if (key_pos(i).x < 8) i ];

/////////////////////////////////////////
// Replicates the original Redox top case
// Sans holes for connectors, see the
// rev0b to see how to do that.
/////////////////////////////////////////
r0_x0 = 88.2;
r0_y0 = -100.8;
r0_x1 = 7.9;
r0_y1 = -1.45;
r0_x2 = 134.7;
r0_x3 = 169.2;
r0_y3 = -75.5;
r0_x6 = 154.32;
r0_y6 = -101.26;
r0_x4 = 145.0;
r0_y4 = -117.6;
r0_x5 = 118.65;
rev0_reference_points = [
    [r0_x0, r0_y0],
    [r0_x1, r0_y0],
    [r0_x1, r0_y1],
    [r0_x2, r0_y1],
    [r0_x3, r0_y3],
    [r0_x6, r0_y6],
    [r0_x4, r0_y4],
    [r0_x5, r0_y4],
    ];
rev0_screw_holes = [ for (p = rev0_reference_points) if (p.x != r0_x4) p];
rev0_tent_positions = [
    // [X, Y, Angle]
    [[3.3, -89.0], 180],
    [[3.3, -13], 180],
    [[145.1, -13], 25],
    [[155.7, -108], -30],
    ];
module rev0_outer_profile() {
    fillet(r = 5, $fn = 20)
        offset(r = 5, chamfer = false)
        polygon(points = rev0_reference_points, convexity = 3);
}
module rev0_top_case() {
    top_case(left_keys, rev0_screw_holes, raised = false) rev0_outer_profile();
}
module rev0_bottom_case() {
    bottom_case(rev0_screw_holes, rev0_tent_positions) rev0_outer_profile();
}

/////////////////////////////////////////////////
// Revised case with bezier based curved outlines
/////////////////////////////////////////////////
r0b_x0 = 88.2;
r0b_y0 = -100.8;
r0b_x1 = 0.9;
r0b_y1 = -3.45;
r0b_y1b = -13.45;
r0b_x2 = 146.7;
r0b_x3 = 169.2;
r0b_y3 = -75.5;
r0b_x6 = 154.32;
r0b_y6 = -101.26;
r0b_x4 = 145.0;
r0b_y4 = -117.6;
r0b_x5 = 118.65;
rev0b_reference_points = [
    [r0b_x0-1, r0b_y0-3],     // Bottom mid
    [r0b_x1, r0b_y0-5],       // Bottom left
    [r0b_x1, r0b_y1],         // Top left
    [r0b_x2, r0b_y1b],        // Top right
    [r0b_x3+2, r0b_y3-6.5],    // Right
    [r0b_x6+5, r0b_y6],        // Screw
    [r0b_x4+5, r0b_y4],        // Bottom
    [r0b_x5+5, r0b_y4],        // Screw
    ];
//rev0b_screw_holes = [ for (p = rev0b_reference_points) if (p.x != r0b_x4+5) p];
rev0b_screw_holes = [
    //[r0b_x1+5, r0b_y0],           // Bottom left
    [r0b_x1+26.5, r0b_y0+18.65],           // Bottom left, under caps

    //[r0b_x1+5, r0b_y1-5],       // Top left
    [r0b_x1+26.5, r0b_y1-6.5],       // Top left
    //[r0b_x1+44.5, r0b_y1-1],      // Top leftish

    //[r0b_x2-13.5, r0b_y1b+3],     // Top right
    [r0b_x2-6.5,  r0b_y3+40],   // Top right, under caps

    //[r0b_x2+4.5,  r0b_y3+7],     // Right
    [r0b_x6-1.5, r0b_y6+0.9],      // Right, under caps

    //[r0b_x5-35, r0b_y4+20],      // Bottom
    ];
rev0b_tent_positions = []; // no tenting holes. I'll create feet later if necessary/
//    // [X, Y, Angle]
//    [[0.8, -18], 180],
//    [[0.8, -91.0], 180],
//    [[146.8, -25], 5],
//    [[151.2, -117.3], -30],
//    ];

      /* CONTROL              POINT                       CONTROL      */
bzVec = [                     [r0b_x1,r0b_y1],            OFFSET([30, 0]), // Top left
         OFFSET([-25, -1]),   [73,4],                     OFFSET([25, 0]), // Top
         POLAR(25, 140),      [r0b_x2,r0b_y1b],           SHARP(), // Top right
         POLAR(32, 153),      [r0b_x3+2,r0b_y3-6.5],      SHARP(), // Right
         // Skip screw
         SHARP(),             [r0b_x4-1.5, r0b_y4-12.5],  POLAR(82, 149), // Bottom right
         POLAR(18, 0),        [r0b_x0-41, r0b_y0-5],      POLAR(5, 180), // Bottom mid
         SHARP(),             [r0b_x1, r0b_y0-5],         SHARP(),
         SHARP(),             [r0b_x1, r0b_y1],
    ];
b1 = Bezier(bzVec, precision = bezier_precision);
module rev0b_outer_profile() {
    offset(r = 5, chamfer = false, $fn = 20) // Purposely slightly larger than the negative offset below
    offset(r = -4.5, chamfer = false, $fn = 20)
        polygon(b1);  
}
module rev0b_top_case(raised = true) {
    top_case(left_keys, rev0b_screw_holes, chamfer_height = raised ? 5 : 2.5, chamfer_width = 2.5, raised = raised) rev0b_outer_profile();
}

module trrs_jack() {
    outside_dia = 10.3;
    outside_length = 3.3;
    inside_dia = 7.7;
    total_length = 16.3;
    rotate(a=[90,0,0]) translate([0,outside_dia/2,-0.27])
    union() {
        cylinder($fn = 180, h = total_length, d = inside_dia, center = false);
        cylinder($fn = 180, h = outside_length, d = outside_dia, center = false);
	intersection() {
	    translate([0,0,outside_length+wall_thickness]) cylinder($fn = 180, h = outside_length, d = outside_dia+0.4, center = false);
	    translate([-6,-outside_dia-3.3,0]) cube([12,10,10]);
	}
    }
}

module usb_c_breakout(hole=true) {
    breakout_width = 21.8;
    breakout_height = 1.5;
    breakout_depth = 13.0;
    usb_c_height = 3.5;
    usb_c_width = 9.25;
    usb_c_depth = 7.4;
    usb_c_overhang = 1.5;
    solder_height = 1.5;
    solder_depth = 3;
    union() {
        color("red") translate([2, -breakout_depth, 0]) cube([breakout_width, solder_depth, solder_height]);
        translate([2,0,solder_height]) {
	    union() {
            color("red") translate([0, -2, breakout_height-0.5]) rotate(a=[5,0,0]) cube([breakout_width, 2, usb_c_height + 6]);
            color("red") translate([0, -breakout_depth, 0]) cube([breakout_width, breakout_depth, breakout_height]);
            color("grey") translate([breakout_width/2 + usb_c_width/2, -usb_c_depth + usb_c_overhang, usb_c_height + breakout_height]) rotate(a=[0,90,90]) roundedcube([usb_c_height, usb_c_width, hole ? usb_c_depth + 3 : usb_c_depth], r=1.5, center=false, $fs=0.05);
	    }
        }
    }
}

module usb_c_support() {
    support_width = 21.8 + 4;	// 2mm extra at both sides
    support_height = 3;	  	// breakout_height + solder_height
    support_depth = 15;		// breakout_depth + 2mm
    difference() {
        translate([0, -support_depth, 0]) cube([support_width,  support_depth, support_height]);
	usb_c_breakout();
    }
}

module rev0b_bottom_case() {
    difference() {
        union() {
          bottom_case(rev0b_screw_holes, rev0b_tent_positions) rev0b_outer_profile();
          translate([0, 0, wall_thickness + 0.01]) {
              translate([32, -2.2, 0.05]) rotate([0, 0, 8.8]) usb_c_support();
	  }
        }

        translate([0, 0, wall_thickness + 0.01]) {
            // Case holes for connectors etc. The second version of each is just
            // For preview view
	    // usb_c_hole();
	    // %usb_c_hole();
            translate([32, -2.2, 0.05]) rotate([0, 0, 8.8]) {
	        usb_c_breakout();
		%usb_c_breakout(hole=false);
	    }
            // translate([34, -8.45, 0.05]) rotate([0, 0, 8.8]) {
            //     reset_microswitch();
            //     %reset_microswitch(hole = false);
            // }
            // translate([13, -5.5, 0]) rotate([0, 0, 4]) {
            //     micro_usb_hole();
            //     %micro_usb_hole(hole = false);
            // }
            //translate([130.5, -7.5, 0]) rotate([0, 0, -24]) {
            //    mini_usb_hole();
            //    %mini_usb_hole(hole = false);
            //}
            $fn=64;
            translate([130.5, -0.1, 0.2]) rotate([0, 0, -21.1]) {
                //mini_usb_hole();
                //%mini_usb_hole(hole = false);
                //cylinder(r=7.85/2, h=20);
                //translate([0, 0, 11.5]) {
                //    cylinder(r=9.8/2, h=4);
                //}
		trrs_jack();
		%trrs_jack();
            }
        }
    }
}

//part = "assembly";
part = "bottom0b";
//part = "bottom0btest";
//part = "top0b";
//part = "top0b-raised";
//part = "keycaps";
//part = "outer";
//part = "usb_c_breakout";
//part = "trrs_jack";

explode = 1;
if (part == "outer") {
    //BezierVisualize(bzVec);
    offset(r = -2.5) // Where top of camber would come to
        rev0b_outer_profile();
    for (pos = rev0b_screw_holes) {
        translate(pos) {
            polyhole2d(r = 3.2 / 2);
        }
    }
    #key_holes(left_keys);
    
} else if (part == "top0") {
    rev0_top_case();

} else if (part == "bottom0") {
    rev0_bottom_case();

} else if (part == "top0b-raised") {
    rev0b_top_case(true);
    
} else if (part == "top0b") {
    rev0b_top_case(false);

} else if (part == "bottom0b") {
    rev0b_bottom_case();

} else if (part == "assembly") {
    %translate([0, 0, plate_thickness + 30 * explode]) key_holes(left_keys, "keycap");
    %translate([0, 0, plate_thickness + 20 * explode]) key_holes(left_keys, "switch");
    rev0b_top_case();
    translate([0, 0, -bottom_case_height -20 * explode]) rev0b_bottom_case();

} else if (part == "holetest") {
    * translate([-66.5, 20.25]) top_case([left_holes[0], left_holes[1], left_holes[7], left_holes[8]], [], raised = true)
        translate([66.5, -20.25]) square([46, 49], center = true);
    translate([-66.5, 20.25]) difference() {
        chamfer_extrude(height = plate_thickness + top_case_raised_height, chamfer = 5, width = 2.5, faces = [false, true]) translate([66.5, -20.25]) square([46, 49], center = true);
        translate([0, 0, 4])
        key_holes([left_holes[0], left_holes[1], left_holes[7], left_holes[8]]);
    }
} else if (part == "keycaps") {
    translate([0, 0, plate_thickness + 30 * explode]) key_holes(left_keys, "keycap");
} else if (part == "usb_c_breakout") {
    $fn=64;
    usb_c_support(); 
    %usb_c_breakout();
} else if (part == "trrs_jack") {
    trrs_jack();
} else if (part == "testusbhole") {
    difference() {
        union() {
            cube([10,20,2]);
            cube([2,20,10]);
        }
        usb_c_height = 3.5;
        usb_c_width = 9.25;
        thickness = 10.0;
        translate([0,10,4]) rotate(a=[0,90,0]) roundedcube([usb_c_height, usb_c_width, thickness], r=1.5, center=true, $fs=0.05);
    }
} else if (part == "bottom0btest") {
    intersection() {
        rev0b_bottom_case();
       // rev0b_top_case();
        translate([110,-45,-10]) cube([42,80,40]);
    }
}



// Requires my utility functions in your OpenSCAD lib or as local submodule
// https://github.com/Lenbok/scad-lenbok-utils.git
use<../Lenbok_Utils/utils.scad>
// Requires bezier library from https://www.thingiverse.com/thing:2207518
use<../Lenbok_Utils/bezier.scad>
