
module SDS011_holes(pcbThickness=1.5, invert=0){
    
    // Left top hole:
    translate([70-5,11,-pcbThickness])cylinder(r=3.2/2,h=pcbThickness*3);
    // Right top hole:
    translate([5,11,-pcbThickness])cylinder(r=3.2/2,h=pcbThickness*3);
    
    
    //Middle bottom hole:
    if(invert){
     translate([70-41-5,55+11,-pcbThickness])cylinder(r=3.2/2,h=pcbThickness*3);   
    } else {
     translate([41+5,55+11,-pcbThickness])cylinder(r=3.2/2,h=pcbThickness*3);
    }
    
}

module SDS011(invert=0){
    
    difference(){
        cube([70,70,1.5]);
        SDS011_holes(invert=invert);
    }
    
}

//SDS011(invert=1);