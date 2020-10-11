include <./SDS011.scad>
include <./NodeMCU.scad>
include <./mhz19.scad>

width = 15;
   module Dove(){
    height = 4;
    
    r= 6;
    translate([-0.5*width,0,-0.5*height])
    hull(){
      cube([width,10,height]);
      cylinder(r=r, h=height, $fn=40);
      translate([width,0,0])cylinder(r=r, h=height, $fn=40);
    }
  }
//cube([segment_total_w,segment_total_h,segment_total_z]);

module segment(segment_width,segment_length,segment_total_z, cut=false){
    
  
  
      if(cut){
      // LED cutout:
  translate([segment_width*0.5+segment_length*0.5,0,0]){
  translate([-5.1/2,-5.1/2,0])cube([5.1,5.1,110]);
translate([0,0,-segment_total_z-100])cylinder(d=10,h=100);
  }} else {

    
  sq = sqrt( pow(segment_width/2,2)*2 );
  
translate([segment_width*0.5,-segment_width*0.5,0])union(){
  cube([segment_length,segment_width,segment_total_z]);
  
  
    
    rotate([0,0,45])cube([sq,sq,segment_total_z]);
    translate([segment_length,0,0])rotate([0,0,45])cube([sq,sq,segment_total_z]);
  }

}
  
}




 cutout_height = 7;
module WireCutCorner(){

 
  segment_distance = 10;
  union(){
  hull(){cylinder(r=1.5/2,h=cutout_height, $fn=30);
  translate([-segment_distance*0.5,-segment_distance*0.5,0])cylinder(r=1.5/2,h=cutout_height,$fn=30);
    };
    
  hull(){cylinder(r=1.5/2,h=cutout_height, $fn=30);
  translate([segment_distance*0.5,-segment_distance*0.5,0])cylinder(r=1.5/2,h=cutout_height,$fn=30);
    };
  }

}

module Cut_Wire_Holes(factor=1){
translate([6*factor,34*factor,-cutout_height+3])rotate([0,0,9*factor])WireCutCorner();
//translate([-5,35,-cutout_height+3])rotate([0,0,-30])WireCutCorner();
translate([-6*factor,-32*factor,-cutout_height+3])rotate([0,0,195])WireCutCorner();


//Ext:
translate([6*factor,-32*factor,-cutout_height+3])rotate([0,0,-210])WireCutCorner();

translate([75*factor,-42*factor,-cutout_height+3])rotate([0,0,205])WireCutCorner();

translate([75*factor,22*factor,-cutout_height+3])rotate([0,0,-30])WireCutCorner();

translate([-75*factor,42*factor,-cutout_height+3])rotate([0,0,25])WireCutCorner();

translate([-75*factor,42*factor,-cutout_height+3])rotate([0,0,25])WireCutCorner();

//Ext:
translate([-5*factor,34*factor,-cutout_height+2])rotate([0,0,-34])WireCutCorner();

translate([-75*factor,-20*factor,-cutout_height+3])rotate([0,0,-210])WireCutCorner();
}

module 7segdisp( segment_width = 28, segment_length = 100, segment_angle = -8, segment_distance = 10,segment_total_z=10, cut=false){  
  
  union(){
  // Middle segment
  rotate([0,0,90])segment(segment_width,segment_length,segment_total_z,cut=cut);

  // Bottom segment:
  // New start coordinate:
  r = (segment_length+segment_width+2*segment_distance);
  row_0_y = sin(segment_angle)*r;
  row_0_x = cos(segment_angle)*r;

  translate([-row_0_x,-row_0_y,0])
  rotate([0,0,90 ])segment(segment_width,segment_length,segment_total_z,cut=cut);


  // New start coordinate:
  y = sin(segment_angle)*segment_distance;
  x = cos(segment_angle)*segment_distance;

  //Right bottom
  translate([-x,-y,0])
  rotate([0,0,segment_angle-180])segment(segment_width,segment_length,segment_total_z,cut=cut);

  //Right Top
  translate([x,y,0])
  rotate([0,0,segment_angle])segment(segment_width,segment_length,segment_total_z,cut=cut);

  //Left bottom:
  translate([-x,-y+r-segment_distance*2,0])
  rotate([0,0,segment_angle-180])segment(segment_width,segment_length,segment_total_z,cut=cut);
  


  
  
  
  //Left top:
  translate([x,y+r-segment_distance*2,0])
  rotate([0,0,segment_angle])segment(segment_width,segment_length,segment_total_z,cut=cut);

  // Top segment:
  translate([row_0_x,row_0_y,0])
  rotate([0,0,90 ])segment(segment_width,segment_length,segment_total_z,cut=cut);
  

  }
}


max_dim_x = 190;
max_dim_y = 160;


segment_width = 10;
segment_length = 52;
segment_angle = -8;
segment_distance=10;
wall_thickness = 3;


m_h = 10;
segment_total_w = 120;
segment_total_h = max_dim_y;
segment_total_zs = 60;
/*
translate([-max_dim_x*0.5,max_dim_y*-0.5,-30])cube([max_dim_x,max_dim_y,30]);
*/

connector_radius = 13/2;
connector_spacing = connector_radius*2.5;
connector_depth = 30;
top_radius = 225;

/*
difference(){
  
  
  color([0,0,0])
  intersection(){
  translate([-(segment_total_h),0,-top_radius+segment_total_zs-5])rotate([0,90,0])cylinder(r=top_radius,h=segment_total_h*2,  $fn = 800);
    minkowski(){
     translate([-(segment_total_h*0.5),-(segment_total_w*0.5),0])cube([segment_total_h,segment_total_w,segment_total_zs-m_h*0.5]);
      sphere(r=10);
    }
  }
  
  
   
translate([-(segment_total_h*0.5)-connector_depth+m_h*2-0.1,-(segment_total_w*0.5)+15,segment_total_zs*0.5])rotate([0,90,0])cylinder(r=connector_spacing,h=connector_depth); 
  
translate([-(segment_total_h*0.5)-connector_depth+m_h*2-0.1,-(segment_total_w*0.5)+15,segment_total_zs*0.5])rotate([0,90,0])cylinder(r=connector_spacing,h=connector_depth);

    minkowski(){
     translate([-(segment_total_h*0.5),-(segment_total_w*0.5),0])cube([segment_total_h,segment_total_w,segment_total_zs]);
      sphere(r=5);
    }


}

*/


  
h=10;

/*
  translate([0,-30,0]){
    
 
difference(){
  minkowski(){
 7segdisp( segment_width, segment_length, segment_angle, segment_distance,20);

cylinder(r=wall_thickness*2,h=0.1);
}
  translate([0,0,wall_thickness])
 minkowski(){
   7segdisp( segment_width, segment_length, segment_angle, segment_distance,20);

  cylinder(r=wall_thickness+0.1,h=0.1);
  }

}}*/

module CENTER(){
     translate([0,-30,0]){
  
    difference(){
    minkowski(){
   7segdisp( segment_width, segment_length, segment_angle, segment_distance,h);
  cylinder(r=wall_thickness*(2.5),h=0.1);
  };
   minkowski(){
   7segdisp( segment_width, segment_length, segment_angle, segment_distance,h);
  cylinder(r=wall_thickness*0.5,h=h);
  }
  
  
}
}
}

/*
h_test = 50;
      difference(){
    minkowski(){ 
   segment( segment_width, segment_length,h_test);
  cylinder(r=wall_thickness*(2),h=0.1);
  };
   minkowski(){
  segment( segment_width, segment_length,h_test);
  cylinder(r=wall_thickness*0.5,h=h);
  }}*/
    
// TOP COVER:
module TOP_COVER(){
inset_h = 4;
color([0.5,0])
translate([0,-30,0]){
  r=wall_thickness*(2.49);
   difference(){
       minkowski(){
     7segdisp( segment_width, segment_length, segment_angle, segment_distance,inset_h*0.5);
    
         intersection(){
          sphere(r=r, $fn=50);
          translate([-r,-r,0])cube([r*2,r*2,r]);
          }
    }
    
      difference(){
    minkowski(){
   7segdisp( segment_width, segment_length, segment_angle, segment_distance,inset_h);
  cylinder(r=wall_thickness*(2.55),h=0.1);
  };
   minkowski(){
   7segdisp( segment_width, segment_length, segment_angle, segment_distance,inset_h);
  cylinder(r=wall_thickness*0.5,h=h);
  }
  
  
}
  
translate([0,0,-0.1]){
   minkowski(){
   7segdisp( segment_width, segment_length, segment_angle, segment_distance,r-0.1+1.1);
  cylinder(r=wall_thickness*0.5*0.1,h=0.1);
  }
    }
  }
}}


module Bottom(){
difference(){
inset_h = 4;
  downset = 2;
  
color([0.5,0])
  union(){
     seg_offset_len = 18;
  translate([-40,58.5,-5.47]){
    rotate([0,0,segment_angle-180]){
    translate([-width,8.1,-2])
    cube([width*2,5,4]); 
    Dove();
    
        
   }
  }
  translate([-40,58.5-120,-5.47]){
    rotate([0,0,segment_angle-180]){
 
       //Recieving end:
  difference(){
  translate([-width,-12-seg_offset_len,-2])cube([width*2,20+seg_offset_len,5.5]); 
  minkowski(){
    Dove();
    sphere(r=0.15/2);
  }}
    }}
    
    
    // SECOND LOWER DOVES:
    
      translate([40,47.2,-5.47]){
    rotate([0,0,segment_angle-180]){
    translate([-width,8.1,-2])
    cube([width*2,5,4]); 
    Dove();
    
        
   }
  }
  translate([40,47.2-120,-5.47]){
    rotate([0,0,segment_angle-180]){
 
       //Recieving end:
  difference(){
  translate([-width,-12-seg_offset_len,-2])cube([width*2,20+seg_offset_len,5.5]); 
  minkowski(){
    Dove();
    sphere(r=0.15/2);
  }}
    }}
    
  
translate([0,-30,0]){
  r=wall_thickness*(2.49);
   difference(){
     
     translate([0,0,0])
       minkowski(){
     7segdisp( segment_width, segment_length, segment_angle, segment_distance,inset_h*0.5);
    
         intersection(){
          translate([0,0,-r])cylinder(r=r, $fn=50,h=r);
          translate([-r,-r,-r])cube([r*2,r*2,r]);
          }
    }
    translate([0,0,-downset])
      difference(){
    minkowski(){
   7segdisp( segment_width, segment_length, segment_angle, segment_distance,inset_h+downset);
  cylinder(r=wall_thickness*(2.55),h=0.1);
  };
   minkowski(){
  
   7segdisp( segment_width, segment_length, segment_angle, segment_distance,inset_h);
  cylinder(r=wall_thickness*0.5,h=h);
  }
  
  
}
  
translate([0,0,-0.10]){
   minkowski(){
        translate([0,0,-6])
   7segdisp( segment_width, segment_length, segment_angle, segment_distance,r-0.1+1.1);
  cylinder(r=wall_thickness*0.5*0.1,h=0.1);
  }
  
    
    }
  }}}
  
  Cut_Wire_Holes(1);
  
   indent_off = 10;
  
  translate([40,47.2-120,-5.5-3])
rotate([0,0,segment_angle])cube([1.5,40,5]);
  
    translate([-40+1,47.2-120+7,-5.5-3])
    rotate([0,0,segment_angle])cube([1.5,40,5]);
  
      translate([-40-1.9,47.2-13,-5.5-3])rotate([0,0,segment_angle])cube([1.5,40,5]);
  
  translate([40-1.9-1.2,47.2-13-9,-5.5-3])rotate([0,0,segment_angle])cube([1.5,40,5]);
  
  
  
  }

}


module Bottom_WO_DOVE(){
difference(){
inset_h = 4;
  downset = 2;
  
color([0.5,0])
  union(){
     seg_offset_len = 18;

  translate([-40,58.5-120,-5.47]){
    rotate([0,0,segment_angle-180]){
 
       //Recieving end:
  difference(){
  translate([-width,-12-seg_offset_len,-2])cube([width*2,20+seg_offset_len,5.5]); 
  minkowski(){
    Dove();
    sphere(r=0.15/2);
  }}
    }}
    
    

  translate([40,47.2-120,-5.47]){
    rotate([0,0,segment_angle-180]){
 
       //Recieving end:
  difference(){
  translate([-width,-12-seg_offset_len,-2])cube([width*2,20+seg_offset_len,5.5]); 
  minkowski(){
    Dove();
    sphere(r=0.15/2);
  }}
    }}
    
  
translate([0,-30,0]){
  r=wall_thickness*(2.49);
   difference(){
     
     translate([0,0,0])
       minkowski(){
     7segdisp( segment_width, segment_length, segment_angle, segment_distance,inset_h*0.5);
    
         intersection(){
          translate([0,0,-r])cylinder(r=r, $fn=50,h=r);
          translate([-r,-r,-r])cube([r*2,r*2,r]);
          }
    }
    translate([0,0,-downset])
      difference(){
    minkowski(){
   7segdisp( segment_width, segment_length, segment_angle, segment_distance,inset_h+downset);
  cylinder(r=wall_thickness*(2.55),h=0.1);
  };
   minkowski(){
  
   7segdisp( segment_width, segment_length, segment_angle, segment_distance,inset_h);
  cylinder(r=wall_thickness*0.5,h=h);
  }
  
  
}
  
translate([0,0,-0.10]){
   minkowski(){
        translate([0,0,-6])
   7segdisp( segment_width, segment_length, segment_angle, segment_distance,r-0.1+1.1);
  cylinder(r=wall_thickness*0.5*0.1,h=0.1);
  }
  
    
    }
  }}}
  
  Cut_Wire_Holes();
  
   indent_off = 10;
  
  translate([40,47.2-120,-5.5-3])
rotate([0,0,segment_angle])cube([1.5,40,5]);
  
    translate([-40+1,47.2-120+7,-5.5-3])
    rotate([0,0,segment_angle])cube([1.5,40,5]);

  
  
  }

}



module Bottom_SMALL(){
  wall_thickness = 1.5;
  orig_r = 3*(2.49);
  segment_width=6;
  segment_length = 52/2.5;
difference(){
inset_h = 2;
  downset = 3;
  
color([0.5,0])
  union(){
     seg_offset_len = 18;


translate([0,-30,0]){
  r= (wall_thickness*(2.49));
   difference(){
     qh = 5;
     translate([0,0,0])
       minkowski(){
     7segdisp( segment_width, segment_length, segment_angle, segment_distance/2.5,inset_h*0.5,cut=0);
    
         intersection(){
          translate([0,0,-orig_r])cylinder(r=r, $fn=50,h=qh);
          translate([-r,-r,-orig_r])cube([r*2,r*2,qh]);
          }
    }
    translate([0,0,-downset])
      difference(){
    minkowski(){
   7segdisp( segment_width, segment_length, segment_angle, segment_distance/2.5,inset_h+downset,cut=0);
  cylinder(r=wall_thickness*(2.55)*2,h=0.1);
  };
   minkowski(){
  
   7segdisp( segment_width, segment_length, segment_angle, segment_distance/2.5,inset_h,cut=0);
  cylinder(r=wall_thickness*0.5,h=h);
  }
  
  
}
  
translate([0,0,-0.10]){
   minkowski(){
        translate([0,0,-6])
   7segdisp( segment_width, segment_length, segment_angle, segment_distance/2.5,r-0.1+1.1, cut=false);
  cylinder(r=wall_thickness*0.5*0.1,h=0.1);
  }
  
    
    }
  }}}
  

  

  
  
  }

}



module 7segdisp_CUTTER( segment_width = 28, segment_length = 100, segment_angle = -8, segment_distance = 10,segment_total_z=10){  
  
  union(){
  // Middle segment
  rotate([0,0,90])segment(segment_width,segment_length,segment_total_z);

  // Bottom segment:
  // New start coordinate:
  r = (segment_length+segment_width+2*segment_distance);
  row_0_y = sin(segment_angle)*r;
  row_0_x = cos(segment_angle)*r;

  translate([-row_0_x,-row_0_y,0])
  rotate([0,0,90 ])segment(segment_width,segment_length,segment_total_z);


  // New start coordinate:
  y = sin(segment_angle)*segment_distance*segment_length*0.5;
  x = cos(segment_angle)*segment_distance*segment_length*0.5;

  //Right bottom
  translate([-x,-y,0]){
translate([-5.1/2,-5.1/2,0])cube([5.1,5.1,5.1]);
translate([0,0,-20])cylinder(d=10,h=20);
  }
  //Right Top
  translate([x,y,0]){
translate([-5.1/2,-5.1/2,0])cube([5.1,5.1,5.1]);
translate([0,0,-20])cylinder(d=10,h=20);
  }

  //Left bottom:

  
     translate([-x,-y+r-segment_distance*2,0]){
translate([-5.1/2,-5.1/2,0])cube([5.1,5.1,5.1]);
translate([0,0,-20])cylinder(d=10,h=20);
  }
  

  //Left top:
  translate([x,y+r-segment_distance*2,0]){
translate([-5.1/2,-5.1/2,0])cube([5.1,5.1,5.1]);
translate([0,0,-20])cylinder(d=10,h=20);
  }

  // Top segment:
  translate([row_0_x,row_0_y,0]){
translate([-5.1/2,-5.1/2,0])cube([5.1,5.1,5.1]);
translate([0,0,-20])cylinder(d=10,h=20);
  }
  }
}




//
module MERGED_BOTTOM(){
difference(){
union(){
  Bottom();
//translate([0,-120,0])Bottom();
  ch = 4;
translate([-75,-28,-7.470])cylinder(r=5,h=ch, $fn=20);
translate([-79,-28,-7.470])cylinder(r=4,h=ch, $fn=20);
translate([-84,-26,-7.470])cylinder(r=4,h=ch, $fn=20);


translate([-106,-28.5,0])
difference(){
Bottom_SMALL();


//segment(segment_width=30,segment_length=100,segment_total_z=20,cut=true);

segment_width=6;
  segment_length = 52/2.5;
inset_h = 4;
  downset = 2;
  
  translate([0,-30,-13+0.1])scale([1.1,0.82,1]){
       7segdisp( 2, segment_length+10, segment_angle, (segment_distance/2.5)-5 ,inset_h+downset,cut=0);
  }
  
translate([0,-30,2]){

   7segdisp( segment_width, segment_length, segment_angle, segment_distance/2.5,inset_h+downset,cut=1);

    }

  }
}
  
xxx = 3;
hull(){
translate([-86+0.5,-30,-7.470])cylinder(r=0.7,h=2);
translate([-83+xxx*0.05,-17+xxx,-7.470])cylinder(r=1.5,h=2, $fn=20);
}

    }
  
  }
  
    
module CENTER_S(){
  
   wall_thickness = 1.5;
  orig_r = 3*(2.49);
  segment_width=6;
  segment_length = 52/2.5;
difference(){
inset_h = 2;
  downset = 3;
  
color([0.5,0])
  union(){
     seg_offset_len = 18;


translate([0,-30,5]){
  r= (wall_thickness*(2.49));
   difference(){
     qh = 5;
     translate([0,0,0])
       minkowski(){
     7segdisp( segment_width, segment_length, segment_angle, segment_distance/2.5,inset_h*0.5,cut=0);
    
         intersection(){
          translate([0,0,-orig_r])cylinder(r=r, $fn=50,h=qh);
          translate([-r,-r,-orig_r])cube([r*2,r*2,qh]);
          }
    }
    translate([0,0,-downset])
      difference(){
    minkowski(){
   7segdisp( segment_width, segment_length, segment_angle, segment_distance/2.5,inset_h+downset,cut=0);
  cylinder(r=wall_thickness*(2.55)*2,h=0.1);
  };

  }
    
  translate([0,0,-10])
     minkowski(){
  
   7segdisp( segment_width, segment_length, segment_angle, segment_distance/2.5,inset_h,cut=0);
  cylinder(r=wall_thickness*0.5+0.1,h=30);
  }
  
  }}}}}
  
  
  module TOP_COVER_S(){
       wall_thickness = 1.5;
  orig_r = 3*(2.49);
  segment_width=6;
  segment_length = 52/2.5;
    
inset_h = 4;
color([0.5,0])
translate([0,-30,0]){
  r=wall_thickness*(2.49);
   difference(){
       minkowski(){
     7segdisp( segment_width, segment_length, segment_angle, segment_distance/2.5,inset_h*0.5);
    
         intersection(){
          sphere(r=r, $fn=50);
          translate([-r,-r,0])cube([r*2,r*2,r]);
          }
    }
    
      difference(){
    minkowski(){
   7segdisp( segment_width, segment_length, segment_angle, segment_distance/2.5,inset_h);
  cylinder(r=wall_thickness*(2.58),h=0.1);
  };
   minkowski(){
   7segdisp( segment_width, segment_length, segment_angle, segment_distance/2.5,inset_h);
  cylinder(r=wall_thickness*0.5,h=h);
  }
  
  
}
  
translate([0,0,-0.1]){
   minkowski(){
   7segdisp( segment_width, segment_length, segment_angle, segment_distance/2.5,r-0.1+1.1);
  cylinder(r=wall_thickness*0.5*0.1,h=0.1);
  }
    }
  }
}}
  
//translate([-106,-28.5,0])CENTER_S();


module CPU(){
difference(){
inset_h = 4;
  downset = 2;
  
color([0.5,0])
  union(){
     seg_offset_len = 18;
  translate([-40,58.5,-5.47]){
    rotate([0,0,segment_angle-180]){
    translate([-width,8.1,-2])
    cube([width*2,5,4]); 
    Dove();
    
        
   }
  }

    
    
    // SECOND LOWER DOVES:
    
      translate([40,47.2,-5.47]){
    rotate([0,0,segment_angle-180]){
    translate([-width,8.1,-2])
    cube([width*2,5,4]); 
    Dove();
    
        
   }
  }

    
  
}
  
  Cut_Wire_Holes(1);
  
   indent_off = 10;
  
  
  
  }

}

module trapezoid(){
translate([0,-10,-7.47]){
difference(){
translate([-185*0.5-5,-22,0])rotate([0,0,segment_angle])cube([185,90,4]);

translate([-270,-30,-15])cube([185,100,30]);
  translate([85,-50,-15])cube([20,100,30]);
  translate([-90,68,-10])cylinder(r=20,h=20,$fn=200);
  translate([-80,68,-10])cylinder(r=20,h=20,$fn=200);
  
}}}

module CPU_INC_holes(){
translate([1,1,0])CPU();
difference(){
trapezoid();
  
  translate([80,-40,0]){
  rotate([0,0,90]){
SDS011_holes(invert=0,pcbThickness=10);

}}

  translate([0,0,-4])scale([0.95,0.88,0.5])trapezoid();


//translate([0,0,40])trapezoid();

$fn = 30;
translate([10,0,0]){
rotate([0,0,90])translate([-1.5,31.5,0])
NodeMCU_HoleDriller(pcbHoleRadius=(3.5/2)*0.95,pcbThickness=50 );

//rotate([0,0,90])translate([-20,30,0])  NodeMCUBaseV1(false);
}

  //Holes for CO2 sensor mount
  translate([-1,-18,-10])cylinder(r=1.5,h=20);
  translate([-1,-3,-10])cylinder(r=1.5,h=20);
  
  
// Holes for something else ..

  translate([-1,-32,-10])cylinder(r=1.5,h=20);
  translate([-1,-3+15,-10])cylinder(r=1.5,h=20);
  translate([-1,-3+35,-10])cylinder(r=1.5,h=20);

// Light sensor mount(s) ?


// Temp sensor mount, far away to reduce mcu temperature impact
translate([77,-47,-10])cylinder(r=1.5,h=20);

// Corner (R bottom)
translate([-77,-26,-10])cylinder(r=1.5,h=20);

//EXTRA:
for(ii=[0:10:60]){
  translate([-77+ii,-26,-10])cylinder(r=1.5,h=20);
}
// L:
translate([-77,45,-10])cylinder(r=1.5,h=20);

// Fill saving circles

  // Below SDS
  hull(){
    translate([45,-3,-10])cylinder(r=25,h=20,$fn=200);
    translate([45-5,-3-9,-10])cylinder(r=25,h=20,$fn=200);
  }

  // Below micro:
  translate([-49,14,-10])cylinder(r=20,h=20,$fn=200);
  
  

}

}

module EXT_COMPONENTS(){
translate([10,0,0]){
rotate([0,0,90])translate([-20,30,0])  NodeMCUBaseV1(false);
}

 translate([80,-40,0]){
  rotate([0,0,90]){
SDS011();
  }}


  
}


EXT_COMPONENTS();


 translate([-5,-25,0])rotate([90,0,90])MHZ19MOUNT();
    translate([-1,-18,-5])cylinder(r=1.5-0.05,h=4);
  translate([-1,-3,-5])cylinder(r=1.5-0.05,h=4);

