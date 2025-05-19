center_hole=20;
tk_base=2;
depth=40;
$fn=50;
union() {
    translate([0,-5,0])
    cylinder(h = tk_base+2, r1 = 3/4*center_hole, r2 = 1/2*center_hole);

    rotate([-90,180,180])
              linear_extrude(height=0.9*depth , scale=2)
                polygon(points=[
                    [0.7 *center_hole, 0],
                    [0.44 *center_hole, tk_base+2],
                    [-0.44*center_hole, tk_base+2],
                    [-0.7*center_hole,0]
                ]);

        }