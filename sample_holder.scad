// open questions: side hole, height, which holes, depth
// more angle in base cut?, whole bigger than objective?
//how far backstop? cut widht exakt as wide as cover plate (60mm) or 1mm offset ??
// more magentic pockets for deeper coverslips
//size of magnet pockets copied from template....
//no curved edges...

//-----------------------paramteters support walls-----------------------//

tk_support=5;                    // thickness of support triangle
side_hole=3;

//---------------------------general parameters--------------------------//

width = 2*tk_support + 65;      // cover glasses mostly (24x60)mm

//---------------------z-mounting plate parameters-----------------------//

height=20;                       //13mm steps
tk_Zplate=11;                    //thickness vertical plate


//------------------------base plate parameters-------------------------//

depth = 45;
tk_base = 2.5;                               //thickness of base plate
center_hole = 0.28*(width-2*tk_support);   //diameter, (40x PlanFLuor = ⌀~30mm) 0.35*65=22.75mm
//6/4*0.35*65=34.125mm


// estimation for optimal depth:
// y-back-stop distance from mounting plate to objective peak: ~50±2mm
// y-front-stop distance from mounting plate to objective peak: ~25±2mm
// ~> coverslip center needs to be between 25mm & 50mm from overhanging z-mounting plate

// --------back stop
//  | 25mm 
// --------front stop
//  | 25mm (from z-mount to objective peak)
// --------objective peak

// center of coverslip: 3/5*depth = 3/5*51 = 30.6mm
// ~> this is between 25mm & 50mm (middle: 37.5mm)
// what would be optimal? 
// coverslip can be moved forward 8mm
// either way the full 25mm could not be used with this depth
// base cut would need to be 50mm deep, current: 2/3*depth = 2/3*51 = 34mm = 3,4cm



// depth xy stage: ~103mm
// overhanging z-mounting plate: ~21±1mm
// adjusted max depth: 82±1mm







//----------------------------------------------------------------------//
//-----------------------building blocks--------------------------------//
//----------------------------------------------------------------------//
$fn=50;


// xy-base
difference(){
    cube([width, depth, tk_base]);
    
    translate([width/2, 2/3*depth + 0.001, -0.001])
        base_cut();
    
    // coverslip 60x24
    x=40; y=24; z=1.1;
    translate([width/2-x/2, 0.36*depth, tk_base-z/2])
        color("red") cube([x,y,z]);
       
    // right edge and back stop
    translate([(width-x-1)/2, 0.36*depth, tk_base-1/2])    
        cube([x+1,40,1]);
        
    //magnetic pockets underneath
    translate([width/2 + 3/4*center_hole + 4.6, 0.7*depth, -0.01])
        cylinder(h=0.7, r1=4.6 ,r2= 4.1);
    
    translate([width/2 - 3/4*center_hole - 4.6, 0.7*depth, -0.01])
        cylinder(h=0.7, r1=4.6 ,r2= 4.1);
    
    //magnet pocket marks on top
    translate([width/2 + 3/4*center_hole + 4.6, 0.7*depth,tk_base-1])
        cylinder(h=1, r=1);
    
    translate([width/2 - 3/4*center_hole - 4.6, 0.7*depth,tk_base-1])
        cylinder(h=1, r=1);


};

//right triangular support
triangular_support();

//left triangular support
translate([width-tk_support,0,0]) triangular_support();

// z-wall
difference() {
    cube([width, tk_Zplate, height]);
    mount_pattern();
}

// vertical support 
translate([width, tk_Zplate, tk_base])
    rotate([0, -90, 0])
        linear_extrude(height = width, scale=1)
            polygon(points=[
                [0, 0],
                [5, 0],
                [0, 5]
                ]);



//----------------------------------------------------------------------//
//-------------------------------modules--------------------------------//
//----------------------------------------------------------------------//

module base_cut(){
    angle = 3/4;
        union() {
            cylinder(h = tk_base+2, r1 = angle*center_hole, r2 = 1/2*center_hole);

            rotate([90,0,180])
              linear_extrude(height=1/2*depth , scale=1)
                polygon(points=[
                    [angle *center_hole, 0],
                    [1/2 *center_hole, tk_base+2],
                    [-1/2*center_hole, tk_base+2],
                    [-angle*center_hole,0]
                ]);
        }
}





//triangular support wall with through hole
module triangular_support(){
    
    difference(){
        polyhedron(
            points = [
                [0         , tk_Zplate, tk_base],         // A (0)
                [0         , depth    , tk_base],         // B (1)
                [0         , tk_Zplate, height],          // C (2)
                [tk_support, tk_Zplate, tk_base],         // D (3)
                [tk_support, depth    , tk_base],         // E (4)
                [tk_support, tk_Zplate, height]           // F (5)
            ],    
            faces = [
                [0, 1, 2],      // ABC
                [1, 4, 5, 2],   // BCFE
                [5,4,3],        // DEF
                [0, 2, 5,3],
                [0,3,4,1]
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
        rotate([180]) import("lib/M6_ext_thread_len5.stl");
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
                        cylinder(h = tk_Zplate, d = counterbore, center=true);
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

// technical drawing μm-translation-plate
//https://www.thorlabs.de/drawings/1b70adf27b72add-E1902AB5-C312-421C-BCE63133A22E285F/PT1_M-AutoCADPDF.pdf














 