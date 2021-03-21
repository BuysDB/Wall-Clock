module MHZ19(slack=0.2,holeLen=1,holeCutter=0){
    
    if(holeCutter==0){
        translate([-0.5*slack,-0.5*slack,-0.5*slack])cube([26.5+0.5*slack,20+0.5*slack,9+0.5*slack]);
    }
    //Top window
    //0.5mm 
    
    translate([0,0.5,9])cube([10.5+0.5*slack,9+0.5*slack,holeLen+0.5*slack]);
    //Side 7.5mm by 10mm
    //offset: 12mm
    translate([12-0.5*slack,20-0.5*slack,1-0.5*slack])cube([10+0.5*slack,holeLen+0.5*slack,7.5+0.5*slack]);
    
    //Circle thing
    translate([5.5,
    //14
    20-5-0.5 //edit, half a milimeter lower
    ,9])cylinder(h=1,r=2.7+slack, $fn=30);
    
    //PCB:
    
}

module MHZ19MOUNT(wallThickness = 1.5){
    slack = 0.2;
    
    height=8;
    mh=-2;
    difference(){
    translate([-wallThickness,-wallThickness,0])cube([26.5+slack+2*wallThickness,20+slack+wallThickness*2,height]);
    translate([0,0,mh])MHZ19(slack=slack,holeLen=5);
    }
    //translate([0,0,mh])MHZ19(slack=0);
}

