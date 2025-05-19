// params in mm
tk = 5;                     // thickness of polymer
width = 80;                // z-microm.plate = 76.2 mm, xy-hole 150mm
depth = 51;                 // hole in xy microm.plate = ~100mm
height = 101.6;             // 101.6 micrometer plate
support_height = height-tk; 

z_mount = 101.6+tk;         // height of z.microm.plate = 101.6mm
hole_diameter = 11;         // head of M6 ?
h_space = 50.8;             // horizontal space btw corner holes = 50 mm 
v_space = 75;               // vertical space btw corner holes= 70 mm 

center_hole = 25;
side_hole = 10;

r= 1;
$fn=20;

// thickness of mounting head holes and threaded holes?
// width, height, depth ??
// holes in the side??
// 
// 

            
// main stage (xy)
difference(){
    //cube([width, depth, tk]);
    hull(){
        for (x = [r, width-r])
            for (y = [r, depth-r])
                for (z = [0, 2-r])
                    translate([x,y,z]) sphere();
        };
    

       translate([width/2, 2/3*(depth+tk), -50+tk])
        sphere(r = 51, $fn=100);
        translate([width/2, 3/5*(depth+tk), -1])  // -1 to ensure hole cuts through
       cylinder(h = tk+2, d = center_hole, $fn = 60);

        

};





difference(){
    // Hauptkörper (mit runden Ecken durch Hull)
    hull(){
        for (x = [r, width - r])
            for (y = [r, depth - r])
                for (z = [0, 2 - r])
                    translate([x, y, z]) sphere(r=r);
    };

    // Loch in der Mitte
    translate([width/2, 3/5*(depth + tk), -1])  // -1 um durchzugehen
        cylinder(h = tk + 2, d = center_hole, $fn = 60);
        
    // Rechteckige Auslassöffnung
    translate([width/2, 4/5*(depth + tk), tk])
        cube([center_hole, 20, tk + 8], center = true);

    // Neue konkave Aussparung an der Unterkante
    translate([width/2, r/2, -1])  // etwas nach vorne versetzt
        rotate([90, 0, 0])
            cylinder(r=15, h=tk + 2, $fn=60);  // halbkreisförmige Rundung
}

// z mounting plate
difference() {
    //cube([width, tk, height]);
    hull(){
        for (x = [r, width-r])
            for (y = [0, tk-r])
                for (z = [r, height-r])
                    translate([x,y,z]) sphere();
        }
    
    
    for(x=[-1:1])
        for(z=[-3:3])
            // two hole array with width h_space/4 
            if (z%2 == 0 && x != 0){
                //thick head holes
                translate([width/2 + x*h_space/4, tk+1, z_mount/2 + z * v_space/6])  
                    rotate([90,0,0])
                        cylinder(h=tk/2, d = hole_diameter, $fn = 50);
                // thin through holes
                translate([width/2 + x*h_space/4, tk/2+2, z_mount/2 + z * v_space/6])  
                    rotate([90,0,0])
                        import("M6_ext_thread_len5.stl");
            }
            // three hole arrays with width h_space/2 
            else if (z%2 !=0 && !(x == 0 && (z == 1 || z == -1))) {
                //thick head holes
                translate([width/2 + x*h_space/2, tk+1, z_mount/2 + z*v_space/6])  
                    rotate([90,0,0])
                        cylinder(h=tk/2, d = hole_diameter, $fn = 50);
                // thin through holes
                translate([width/2 + x*h_space/2, tk/2+3, z_mount/2 + z*v_space/6])  
                    rotate([90,0,0])
                        //cylinder(h=tk+2, d = 6, $fn = 50);
                        import("M6_ext_thread_len5.stl");
            }
            // wide through hole in center
            else if (x == 0 && (z == 1 || z == -1))
                translate([width/2 + x*h_space/2, tk+1, z_mount/2 + z*v_space/6])  
                    rotate([90,0,0])
                        cylinder(h=tk+2, d = hole_diameter, $fn = 50);
            
};

//test +25.4*z-1.2*r ,
//translate([13.1-0.4*r+25.4*2, 0 , 13.3-0.8*r+2*25.4]) rotate([90,0,0]) cylinder(h=2, d=hole_diameter,center=true);  


// right triangular support wall
difference(){
    polyhedron(
        points = [
            [0, 0, 0],                    // A (0)
            [0, depth, 0],                 // B (1)
            [0, 0, tk + support_height],   // C (2)
            [tk, 0, 0],                   // D (3)
            [tk, depth, 0],                // E (4)
            [tk, 0, tk + support_height]   // F (5)
        ],    
        faces = [
            [0, 1, 2],      // ABC
            [1, 4, 5, 2],   // BCFE
            [5,4,3],        // DEF
            [0, 2, 5,3],
            [0,3,4,1]
        ]
    );
    
    translate([-1, depth/2, support_height/3])
        rotate([0, 90, 0])
            cylinder(h = tk+2, d = side_hole, $fn = 50);
};

hull() {
    translate([r, depth-r, r])                  sphere(r);  // B (1)
    translate([r, +r, tk + support_height-r])    sphere(r);  // C (2)
    translate([tk-r, +r, tk + support_height-r]) sphere(r);  // F (5)
    translate([tk-r, depth-r, r])               sphere(r);  // E (4)
}



// left triangular support wall 
translate([width, 0, 0]) {
    
    difference(){
        polyhedron(
            points = [
                [0, 0, 0],                    // A (0)
                [0, depth, 0],                 // B (1)
                [0, 0, tk + support_height],   // C (2)
                [-tk, 0, 0],                  // D (3)
                [-tk, depth, 0],               // E (4)
                [-tk, 0, tk + support_height]  // F (5)      
            ], 
            faces = [
                [2, 1, 0],      // ABC
                [1, 2, 5, 4],   // BCFE
                [3,4,5],        // DEF
                [0, 3, 5, 2],
                [0,1,4,3]
            ]
        );
        translate([-tk-1, depth/2, support_height/3])
            rotate([0, 90, 0])
                cylinder(h = tk+2, d = side_hole, $fn = 50);
    };
    
    hull() {
        translate([-r, depth-r, r])                sphere(r);      // B (1)
        translate([-r, r, tk + support_height-r])    sphere(r);  // C (2)
        translate([-tk+r, r, tk + support_height-r]) sphere(r);  // F (5)
        translate([-tk+r, depth-r, r])                 sphere(r);  // E (4)
    }

}
if (width >= 125){
    
    // right bottom support for support
        polyhedron(
            points=[
                [0,0,0],    
                [width/3,0,0],   
                [0,0.6*depth,0],   
                [0,0,height]    
            ],
            faces=[
                [2,1,0],    
                [0,1,3],    
                [1,2,3],    
                [2,0,3]     
            ]
        );



    // left bottom support for support
    translate([width, 0,0])
        polyhedron(
            points=[
                [0,0,0],    
                [-width/3,0,0],   
                [0,0.6*depth,0],   
                [0,0,height]    
            ],
            faces=[
                [2,1,0],    
                [0,1,3],    
                [1,2,3],    
                [2,0,3]     
            ]
        );

}