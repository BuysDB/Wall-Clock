// Airstation
include <./kicad-ESP8266-master/ESP8266.3dshapes/ESP-12E.scad>





// pin_headers.scad
//
// Model of through-hole pin headers. 
// 
// Units are metric
//
// "height" is the total length of the pin. Default is 12mm.
// "upper" is the length of the pin above the stopper. Default is 7mm.
// "rows" is the number of rows. Default is 3.
// "cols" is the number of columns. Default is 2.
//
// Examples:
// pin_header( 12, 7, 2, 5);
// pin_header( rows=5 cols=1 );
// By Paul McGovern

module pin_header( height=12, upper=7, rows=3, cols=2 ) {

	cl = 2.54;

	translate( [ -(rows  * cl/2 ) + cl /2, -(cols  * cl/2 ) + cl /2, 0 ] ) {

		for( col = [0: cols -1 ] ) {
			for( row = [0 : rows -1 ] ) {

				translate( [ cl * row , cl * col, 0] ) {
	
					color( "gray" )
						translate( [0,0, cl / 2]) {
							intersection() {
								cube( [ cl, cl, cl ], center=true );
								rotate( [0, 0, 45] ) cube( [ 2.8, 2.8, cl ], center=true );
						}
				}

				color( "silver" ) {
					translate( [0,0, (upper - ( height/2 )) + cl ] ) {
						union() {
							cube( [0.64,0.64,height], center=true );
							translate( [0,0, height/2 ] ) scale( 0.64 ) _pin_point();
							translate( [0,0, -height/2 ] ) scale( 0.64 )	rotate([180,0,0] )_pin_point();
						}
					}
				}
			}
		}
	}
}
}

module _pin_point() {
	translate( [-0.5,-0.5, 0])
		polyhedron( 
			points=[[0,0,0],[0,1,0],[1,1,0],[1,0,0],[0.5,0.5,0.5]], 
			triangles=[[0,1,2],[0,2,3],[0,1,4],[1,2,4],[2,3,4],[3,0,4]]);
}

$fn = 15;


// Esp 8266 module
module ESP8266(){
    esp8266height = 3;
    esp8266boardDimensions = [16,24.5,0.8];
    esp8266canSize = [11.1,15.5,esp8266height-0.8];
    color([0.1,0.1,0.1])cube(esp8266boardDimensions);
    color([0.75,0.75,0.75])translate([2,8.0,0.8])cube(esp8266canSize);
    
}

module NodeMCU_HoleDriller( 
    pcbHoleRadius = 3.5/2, 
    pcbThickness=1.5,
    dimensions = [31.5,57.5,13.0],
    distanceToEdgeY = 2,
    distanceToEdgeX = 2,
    distanceBetweenHolesX = 25,
    distanceBetweenHolesY = 52
){
       
       //PCB holes for mounting:
    xCenters = [
    distanceToEdgeX+0.5*pcbHoleRadius, 
    distanceToEdgeX+0.5*pcbHoleRadius+distanceBetweenHolesX ];
    //dimensions[0]-distanceToEdgeX-0.5*pcbHoleRadius
    
    //yCenters = [distanceToEdgeY+0.5*pcbHoleRadius, ,dimensions[1]-distanceToEdgeY-0.5*pcbHoleRadius];
    yCenters = [distanceToEdgeY+0.5*pcbHoleRadius, distanceToEdgeY+0.5*pcbHoleRadius+distanceBetweenHolesY];
    
    translate([xCenters[0],yCenters[0], -0.5*pcbThickness])cylinder(r=pcbHoleRadius, h=pcbThickness*2);
     translate([xCenters[1],yCenters[1], -0.5*pcbThickness])cylinder(r=pcbHoleRadius, h=pcbThickness*2);
     translate([xCenters[0],yCenters[1], -0.5*pcbThickness])cylinder(r=pcbHoleRadius, h=pcbThickness*2);
     translate([xCenters[1],yCenters[0], -0.5*pcbThickness])cylinder(r=pcbHoleRadius, h=pcbThickness*2);
   
}

module NodeMCU(onlyPorts=false){
    dimensions = [31.5,57.5,13.0];
    pcbThickness=1.5;
    topToPcb = 4.5; //Distance from the highest peak to pcb start in Z axis

    
    legHeight = dimensions[2]-pcbThickness-topToPcb;
    if(onlyPorts==false){
        difference(){
            color([0.15,0.15,0.15])cube([dimensions[0], dimensions[1],pcbThickness]);
            NodeMCU_HoleDriller();
        }
        translate([dimensions[0]/2,0,pcbThickness])rotate([0,0,180])ESP12E(); //ESP8266();
    }
    
    headerToEdgeY = 9.5;
    headerToEdgeX = 3-0.32;
    if(onlyPorts==false){
        rotate([180,0,0])translate([headerToEdgeX,-dimensions[1]*0.5,0])pin_header(rows=1,cols=15);
        rotate([180,0,0])translate([dimensions[0]-headerToEdgeX,-dimensions[1]*0.5,0])pin_header(rows=1,cols=15);
    }
    //Micro usb connector
    usbHeight=3;
    overhang = 1.5; // The port sticks a bit out
    translate([dimensions[0]*0.5, dimensions[1]+overhang - 0.5*5.5,pcbThickness+0.5*usbHeight])color("silver")cube([7.5,5.5,3],center=true);
 
};

module GeneralCaddy(
        dimensions=[25,50,1], 
        mountingHoleRadius=1.5
    ){
    difference(){
        cube(dimensions);
        translate([dimensions[0]*0.5,dimensions[1]-mountingHoleRadius-2,dimensions[2]*0.5])cylinder(r=mountingHoleRadius,h=dimensions[2]*2,center=true);
    };

}

module BarelPlugSocket(dimensions=[9.,14,11], barelradius=6.0/2, outlineOnly=false){
    
    if(outlineOnly){
        cube(dimensions);
    }
    else {
         color([0,0,0])difference(){
        cube(dimensions);
            translate([dimensions[0]/2, dimensions[1]+0.1, 3.5+barelradius] )rotate([90,0,0])cylinder(r=barelradius,h=11.5);
        }
    }    
}

module CJMCU(){
    dimensions = [21.5,26.2,1.5];
    color([0.2,0.2,0.2])cube(dimensions);
    translate([2.54,dimensions[1]/2,1.5])pin_header(rows=2,cols=10);
        translate([dimensions[0]-1.5,dimensions[1]/2,1.5])pin_header(rows=1,cols=10);
    
    color([0,0,0])translate([dimensions[0]/2 + 1 ,dimensions[1]/2,1.5])cube([11,6,2.0],center=true);
}


module SHT3X(multiFact=0){
    //Board:
    dimensions = [10.5+multiFact,13.5+multiFact,1.5+multiFact];
    holeRadius = ( (3.0+multiFact) /2);
    shtSize = [2.5+multiFact,2.5+multiFact,1+multiFact];
    dimensions=[10.5,13.5,1.5+multiFact];
    /*
    echo(dimensions);
    holeRadius=holeRadius*multiFact;
    shtSize=shtSize*multiFact;*/

    difference(){
    translate([0,0,0.5*dimensions[2]])color([0.2,0.2,0.2])cube(dimensions,center=true);
    translate([
        -dimensions[0]*0.5+holeRadius+1.5-multiFact*0.5,
        -dimensions[1]*0.5+holeRadius+1.5-multiFact*0.5,
        -0.5*dimensions[2]])cylinder(h=dimensions[2]*2, r=holeRadius);
    }
    translate([0,dimensions[1]*0.5-2.54*0.5,dimensions[2]])pin_header(rows=4, cols=1);
    
    
    edgeDistX = 2;
    edgeDistY = 2.5;
    shtOffset = [dimensions[0]*0.5-edgeDistX-shtSize[0]*0.5, -dimensions[1]*0.5-0.5*shtSize[1]+edgeDistY, -1];//[2.5,3,-1];
    translate(shtOffset)cube(shtSize);
    
}
//SHT3X(1);
module OLED0_96(mount=false,holeDepth=1.5*3,expandSize=0, holes=true){
    $fn=30;
    union(){
        
    boardSize=[27.2,1.5,28];
    
    lcdScreenSize=[25,1.0,13.5];
    distanceFromTopToScreenEdge = 5;
    radius = 1.5;
    length = 5;
    offsetX = 1;
    offsetZ = 1;
    xR = boardSize[0]*0.5-radius-offsetX;
    xL = -boardSize[0]*0.5+radius+offsetX;
    zB = boardSize[2]*0.5-radius-offsetZ;
    zT = -boardSize[2]*0.5+radius+offsetZ;
    y = boardSize[1];
    
    // Holes:
    lowerHoleWidth = 12.0;
    lowerHoleHeight = 3;
    ycHole = holeDepth*0.5;
    ycCube = -holeDepth*0.5;
    
    if(!mount){
        translate([-lcdScreenSize[0]*0.5,boardSize[1]*0.5,-0.5*boardSize[2]+distanceFromTopToScreenEdge])cube(lcdScreenSize,center=false);

        difference(){
            cube([
                boardSize[0]+expandSize,
                boardSize[1]+expandSize,
                boardSize[2]+expandSize],
            
            center=true);
            //Holes:
           
            
            if(holes){
            //*0.5+lowerHoleHeight
           //translate([0,0,boardSize[2]*0.5-lowerHoleHeight*0.4999])cube([lowerHoleWidth,boardSize[1]*2, lowerHoleHeight],center=true);
        
            
            //Lower right:
            translate([xR,y,zB])rotate([90])cylinder(r=radius,h=boardSize[1]*2);
            translate([xR-length+2*radius,y,zB])rotate([90])cylinder(r=radius,h=boardSize[1]*2);
            translate([xR-length+radius*2,-boardSize[1],zB-radius])cube([length-radius*2,radius*2, radius*2]);
            
            //Lower Left:
            translate([xL,y,zB])rotate([90])cylinder(r=radius,h=boardSize[1]*2);
            translate([xL+length-2*radius,y,zB])rotate([90])cylinder(r=radius,h=boardSize[1]*2);
            translate([xL,,-boardSize[1],zB-radius])cube([length-radius*2,radius*2, radius*2]);
            
                    
            //Top right:
            translate([xR,y,zT])rotate([90])cylinder(r=radius,h=boardSize[1]*2);
            translate([xR-length+2*radius,y,zT])rotate([90])cylinder(r=radius,h=boardSize[1]*2);
            translate([xR-length+radius*2,-boardSize[1],zT-radius])cube([length-radius*2,radius*2, radius*2]);
            
            //Top Left:
            translate([xL,y,zT])rotate([90])cylinder(r=radius,h=boardSize[1]*2);
            translate([xL+length-2*radius,y,zT])rotate([90])cylinder(r=radius,h=boardSize[1]*2);
            translate([xL,,-boardSize[1],zT-radius])cube([length-radius*2,radius*2, radius*2]);
        }
        }
    } else {
        union(){
        radius = radius*0.85;
        length=length*0.85;
                    //Lower right:
            translate([xR,ycHole,zB])rotate([90])cylinder(r=radius,h=holeDepth);
            translate([xR-length+2*radius,ycHole,zB])rotate([90])cylinder(r=radius,h=holeDepth);
            translate([xR-length+radius*2,ycCube,zB-radius])cube([length-radius*2,holeDepth, radius*2]);
            
            //Lower Left:
            translate([xL,ycHole,zB])rotate([90])cylinder(r=radius,h=holeDepth);
            translate([xL+length-2*radius,ycHole,zB])rotate([90])cylinder(r=radius,h=holeDepth);
            translate([xL,ycCube,zB-radius])cube([length-radius*2,holeDepth, radius*2]);
            
                    
            //Top right:
            translate([xR,ycHole,zT])rotate([90])cylinder(r=radius,h=holeDepth);
            translate([xR-length+2*radius,ycHole,zT])rotate([90])cylinder(r=radius,h=holeDepth);
            translate([xR-length+radius*2,ycCube,zT-radius])cube([length-radius*2,holeDepth, radius*2]);
            
            //Top Left:
            translate([xL,ycHole,zT])rotate([90])cylinder(r=radius,h=holeDepth);
            translate([xL+length-2*radius,ycHole,zT])rotate([90])cylinder(r=radius,h=holeDepth);
            translate([xL,ycCube,zT-radius])cube([length-radius*2,holeDepth, radius*2]);
        }
    }
}
}




/*
difference(){
    union(){
    //translate([0,1,0])cube([27.2,1,27.2],center=true);
    translate([0,1,0])cube([35.2,1,27.2],center=true);
        translate([0,-1,0])OLED0_96(1,expandSize=1);
        
    };
    OLED0_96(expandSize=0.4);
    

}*/


module MHZ19(slack=0.2){
    cube([26.5+slack,20+slack,9+slack]);
    
}

/* MHZ bracket
h=2;
sideWidth = 10;
//MHZ19();
difference(){
    union(){
        translate([0.1,-2,0])cube([2,24,11]);
        translate([10.1+2,-2,0])cube([2,24,11]);
        translate([10.1+2,-2,0])cube([2,24,11]);
        translate([0,-sideWidth,0])cube([18.5,20+sideWidth*2,h]);
    }
    x=4;
    y=25.0;

    translate([x,y,-0.1])cylinder(h=h*2,r=1.5, $fn=20);
    translate([x+10,y,-0.1])cylinder(h=h*2,r=1.5, $fn=20);
    MHZ19();
    
    y2=y-30;
    x=4;
    translate([x,y2,-0.1])cylinder(h=h*2,r=1.5, $fn=20);
    
    
    translate([x+10,y2,-0.1])cylinder(h=h*2,r=1.5, $fn=20);
    MHZ19();
}
MHZ19();
*/



module NodeMCUBaseV1(onlyPorts=false){
    
    baseDimensions = [60.5, 60, 1.5];
    mcuDimensions = [31.5,57.5,13.0];
    
    mcuOffset = [18.5, 1, 14-1.5*2];
    headerToEdgeY = 9.5;
    headerToEdgeX = 3-0.32;
    
    if(onlyPorts==false){
        difference(){
            color([0.15,0.15,0.15])cube([baseDimensions[0], baseDimensions[1],pcbThickness]);
            translate([mcuOffset[0], mcuOffset[1], 0])NodeMCU_HoleDriller();
        };
                
        translate([mcuOffset[0], mcuOffset[1], baseDimensions[2]/2])translate([headerToEdgeX-5.0 -2.54*2,mcuDimensions[1]*0.5,0])pin_header(rows=4,cols=15);
        translate([mcuOffset[0], mcuOffset[1], baseDimensions[2]/2])
            translate([mcuDimensions[0]+headerToEdgeX+0.5,mcuDimensions[1]*0.5,0])pin_header(rows=1,cols=15);

    };
    
    translate(mcuOffset)
        NodeMCU(onlyPorts=onlyPorts);
    
    translate([baseDimensions[0]-9,baseDimensions[1]-14+3.2,baseDimensions[2]])BarelPlugSocket(outlineOnly=onlyPorts);
    
}

//NodeMCUBaseV1(false);
