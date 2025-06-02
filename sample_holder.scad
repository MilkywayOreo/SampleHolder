/*
 * Sample Holder for Microscope
 * -------------------------------------
 * Author: Max Hirsch - hirscher@hu-berlin.de
 * Date: May 2025
 * Version: 1.1
 - remove vertical support, 
 - remove 1mm from backstop and right edge section
 - increased iwidth for coverslide 75mm long
 *
 * Description:
 * This OpenSCAD model creates a microscope sample holder with bottom optical access. Compatible with Thorlabs PT1/M mm-plate. Features magnetic clamps for holding slides.
 *
 * License:
 * You are welcome to make free use of this software.
 * Retention of authorship credit is appreciated.
 *
 */

//--------------------------------paramters--------------------------------//

$fn=60;

//thickness of walls
tk_support=5;                    
tk_base = 2.5; 
tk_zmount=11;     

width = 85; 
height = 32.5;                       // 12.5mm steps / hole_array
depth = 50 - tk_zmount;            // > 25
after_cut_depth = 12.5;   


center_hole_diameter = 0.35*width;         // 85*0.35 = 29.75mm
side_hole=3;
      



//      |                                             |     
//      |                   manual z                  |
//      |                mm-transl-plate              |         
//      |                                             |         
//      |=============================================|   
//   ^  ||      ^              ^                     ||         
//   |  ||      v            12.5mm                  ||                           
//   |  ||----11mm-------______v______---------------||        
//   |  ||              |             |              ||    
//   |  ||             |               |             ||     ^---- y = 12.5mm          
//  50  ||            |                 |            ||     |         
//   mm ||           |        Ob  -------|-----------||-----+     y-translate  
//   |  ||           |       jec  -------|-----------||-----+     manual      
//   |  ||           |       tiv         |           ||     |   
//   |  ||           |                                      v---- y = -12.5m               
//   |  ||           |                                    
//   v  ||           |                     
                                                                           

                                           
//--------------------------------main geometry--------------------------------//
 
mag_rad = 4;


// xy-base
difference(){
    cube([width, depth, tk_base]);
    
    translate([width/2,  after_cut_depth +center_hole_diameter/2,0])
        base_cut();
    
    // coverslide example
    x=75; y=25; z=0.1;
    translate([tk_support,  tk_zmount, tk_base])
        color("red") cube([x,y,z]);
       
 
     
    // magnets
    for(x=[-1,1]) {
        translate([width/2 + x*(3/5*center_hole_diameter + mag_rad+0.5),  after_cut_depth+center_hole_diameter/2 - mag_rad, -0.01]) {
            // magnet pocket underneath
            cylinder(h=0.7, r1=mag_rad+0.5, r2=mag_rad);

            // mark on top
            translate([0, 0, tk_base-1]) cylinder(h=1, r=1);
        }
    } 
};


//right triangular support
triangular_support();

//left triangular support
translate([width-tk_support,0,0]) triangular_support();


// z-wall
difference() {
    cube([width, tk_zmount, height]);
    mount_pattern();
}


//// vertical triangluar support
//translate([width, 0, 0])
//    rotate([180, 90, 0])
//        linear_extrude(height = width, scale=1)
//            polygon(points=[
//                [0, 0],
//                [4, 0],
//                [0,  after_cut_depth - tk_zmount - center_hole_diameter/2 - 2]
//                ]);




//-------------------------------modules--------------------------------//



module base_cut(){
    angle = 4/7;
        union() {
            cylinder(h = tk_base, r1 = angle*center_hole_diameter, r2 = 1/2*center_hole_diameter);

            rotate([90,0,180])
              linear_extrude(height=1/2*depth , scale=1)
                polygon(points=[
                    [angle *center_hole_diameter, 0],
                    [1/2 *center_hole_diameter, tk_base],
                    [-1/2*center_hole_diameter, tk_base],
                    [-angle*center_hole_diameter,0]
                ]);
        }
}





//triangular support wall with through hole
module triangular_support(){
/*    
      C
     /|\
   F|\| \
    | \  \ 
    | |\  \
    | | \  \
    |A|__\__\B
    |/    \ /
    D------E
*/    
    difference(){
        polyhedron(
            points = [
                [0         , tk_zmount, tk_base],         // A (0)
                [0         , depth    , tk_base],         // B (1)
                [0         , tk_zmount, height],          // C (2)
                [tk_support, tk_zmount, tk_base],         // D (3)
                [tk_support, depth    , tk_base],         // E (4)
                [tk_support, tk_zmount, height]           // F (5)
            ],    
            faces = [
                [0, 1, 2],      // ABC
                [1, 4, 5, 2],   // BCFE
                [5,4,3],        // DEF
                [0, 2, 5,3],    // ACFD
                [0,3,4,1]       // ADEB
            ]
        );
        
        translate([-1, 3/5*depth, 1/3*height])
            rotate([0, 90, 0])
                cylinder(h = tk_support+2, d = side_hole);
    };

}


// M6 screw length: total:18mm, μm-plate:7mm, head=6mm, ~> 5mm thread ~> y=5/11
head_len = 6;
thread = 5;
counterbore = 11; 

module screw() {
    union() {
        cylinder(h = head_len + 0.6, d = counterbore);
        rotate([180])  // scale([1.04,1.04,1]) import("lib/M6_ext_thread_len5.stl");
        cylinder(h=5, d=6.2);   // 2mm clearence
    }
}


z_max = 101.6;                 
h_space = 50;                  
v_space = 75;                   
      
module mount_pattern(){
    for(x=[-1:1])
        for(z=[-3:3])
            
            translate([
                width/2 + x/2 * h_space,
                thread, 
                z_max/2 + z/6 * v_space]){
   
                    rotate([-90,0,0]){ 

                    //three hole arrays
                    if (z%2 != 0)
                        screw();
                    
                    //two hole arrays
                    if (z%2 == 0 && x != 0)
                        translate([-x/4 * h_space, 0, 0])
                            screw();
                    
                    // full hole
                    if (x == 0 && (z == -1 || z == 1))
                        cylinder(h = tk_zmount, d = counterbore, center=true);
                }
            }
}

//        z_max          
//      =101.6mm   x = 1   x = 0   x = -1
//            ^   
//            |              |   
//     ^  3/6 -    0         0         0         z = 3
//     |      |              |
//     |  2/6 -         0    |    0              z = 2
//     |      |              |
//  v  |  1/6 -    0         X         0         z = 1
//  s  |      |              |
//  p 75mm    ----------0----|----0---------     z = 0
//  a  |      |              |         
//  c  | -1/6 -    0         X         0         z =-1
//  e  |      |              |         
//     | -2/6 -         0    |    0              z =-2
//     |      |              |         
//     v -3/6 -    0         0         0         z =-3
//            |              |   
//            +----|----|----|----|----|----> x_max=76.2mm
//               -1/2 -1/4       1/4  1/2
//                 <--------50mm------->
//                         hspace

// technical drawing mm-translation-plate
// https://www.thorlabs.com/thorproduct.cfm?partnumber=PT1/M














 