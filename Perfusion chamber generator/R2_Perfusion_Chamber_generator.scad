//************************************//
//************************************//
//    Perfusion Chamber Generator     //
//    Ian Kinstlinger, MillerLab      //
//    Updated 5/4/2021               //
//************************************//
//************************************//

//////////////////////////////////////
//Gel dimensions
//////////////////////////////////////

GelLength = 12; //mm
//The script will automatically make the chamber 2mm longer than the gel to give clearance for catheters and repositioning
GelWidth = 8; //mm
GelHeight = 4; //mm
//Some features may not work in gels <3mm tall

nameText1 = "";
nameText2 = "";
// Optionally add engraved text to label your model
// **Make sure the name is short enough to fit on the chamber**
// There is no coded length limit because the limit depends on chamber size
// For no engraved text, leave empty quotes

////////////////////////////////////////
//What component to generate? Only one should be enabled at a time!
////////////////////////////////////////

GenerateBody = 1;
GenerateGasketMold = 0;
GenerateLid = 0;

//ONLY turn one on at a time

///////////////////////////////////////////////
//Perfusion chamber style; 0 for no, 1 for yes
///////////////////////////////////////////////

Fins = 0; //To mount in a vertical holder
SolidBottom = 0; //Choose no (0) if you need to image through the bottom!
PDMSTraps = 1; //To add features to help with PDMS adhesion for glass slides
//NOTES: if making a solid bottom, PDMS traps should be off (no glass to adhere)
// Currently PDMS traps are not supported if extra screws are used
NeedlePDMS = 1; //Add empty space to create a PDMS gasket for your catheter tips
ExtraScrews = 0; //6 screw instead of 4

//*************************************
//Parameters you may want to change
//*************************************

InletOutletZOffset = 0; 
//If the inlet and outlet are not at the center of their respective faces of the gel, what is their offset? If lower then center, use a negative offset

NeedleGauge = 19;

TroughWidth = 2; //How wide is the trough which holds the PDMS gasket?
TroughDepth = 1; //How deep is the trough which holds the PDMS gasket?

xScrewOffset = 8.5; //Spacing screws along gel long side
yScrewOffset = 3; //Spacing screws along gel short side

GasketHeight = 1.5;
LidHeight = 2.5; //mm

//*************************************
//Parameters that should mostly stay the same
//*************************************

ChamberHeightOffset = 0; //Changes the overall height of the chamber without affecting gel chamber placement or dimensions

GelExtLength = GelLength + 2; //Add 2 mm to give space to maneuver and visualize catheters
InOutThick = 26; //mm //Adjust this to change how much the tip sticks into the gel channel
SpaceforScrews = 18; //mm //Width of solid region where the screws go through
TipBooleanDist = 11; //mm //This controls the gemetry of where the Nordson tip is wedged into the chamber

OffsetRad = 5; //This controls the filleted corner curvature
SlideWidth = 25; //Standard microscope slide is 25mm.

NeedleGaskWidth = 5;
NeedleGaskDist = 5;

textSize = 3.5;

screwNutTolerance = 0.3;
lidTolerance = 0.25;

//**************************************
//Inlet and outlet settings
//**************************************

PortsVector = [
[0, 0, InletOutletZOffset, TipBooleanDist, NeedleGauge, 1],
];


//********************************
//Below here the geometry is built
//********************************

$fn=100; //Sets the resolution of the geometry


if (GenerateBody==1){
    chamber();
}
if (GenerateLid==1){
    lid();
}
if (GenerateGasketMold == 1){
    gasketMold();
}


module chamber(){

    difference(){
       
        union(){
            makeBody();
            
            if(Fins == 1){
                fins();
            }
        }
        
        //Here come all the things subtracting from the initial solid block
        
        translate([0,0,ChamberHeightOffset/2]) cube([GelExtLength, GelWidth,GelHeight+ChamberHeightOffset], true); //Main gel cavity
        
        if (PDMSTraps == 1 && SolidBottom != 1){
            PDMSTraps();  
        }
        
        for (i = [0 : len(PortsVector)-1]){
            createPort(PortsVector[i]);
        }
        
        //Make the trough for the PDMS gasket
        //2mm is hardcoded as the space between the gel chamber and the trough
        
        difference(){
            translate([0,0,(GelHeight-TroughDepth)/2+ChamberHeightOffset])cube([GelExtLength+2+TroughWidth*2, GelWidth+2+TroughWidth*2,TroughDepth], true);
                
            translate([0,0,(GelHeight-TroughDepth)/2+ChamberHeightOffset])cube([GelExtLength+2, GelWidth+2, TroughDepth], true);
        }
        
        //Holes for screws and traps for nuts
        
        screwsAndNuts();
        
        labelText();
        
        //translate([0,0,-GelHeight]) cube([5*GelExtLength,5*GelWidth,5*GelHeight], center = false); //uncomment this line to see the cross-section
    
    } //end of difference() 
    
} //end of chamber module


module lid(){
    //translate([0,0,GelHeight/2 + LidHeight/2 + (GasketHeight-TroughDepth)])

difference(){

hull(){ //lid
    translate([xScrewOffset+GelExtLength/2+1, yScrewOffset+SlideWidth/2+1, 0]) cylinder(r = 3, h = LidHeight, center = true);
    translate([-xScrewOffset-GelExtLength/2-1, yScrewOffset+SlideWidth/2+1, 0]) cylinder(r = 3, h = LidHeight, center = true);
    translate([xScrewOffset+GelExtLength/2+1, -yScrewOffset-SlideWidth/2-1, 0]) cylinder(r = 3, h = LidHeight, center = true);
    translate([-xScrewOffset-GelExtLength/2-1, -yScrewOffset-SlideWidth/2-1, 0]) cylinder(r = 3, h = LidHeight, center = true);
    
}

//Make holes in lid for M3 screws

if(ExtraScrews == 0){

    for (xScrewDir = [-1,1]){
    for(yScrewDir = [-1, 1]){
            
    translate([xScrewDir*(xScrewOffset+GelExtLength/2), yScrewDir*(yScrewOffset+SlideWidth/2), 0]) cylinder(r = screwNutTolerance+1.5, h = 2*GelHeight, center = true);
        // 1.5mm is hardcoded as the radius of an M3 screw
        
    }
}
}


if(ExtraScrews == 1){

    for (xScrewDir = [-1,0,1]){
    for(yScrewDir = [-1, 1]){
            
    translate([xScrewDir*(xScrewOffset+GelExtLength/2), yScrewDir*(yScrewOffset+SlideWidth/2), 0]) cylinder(r = screwNutTolerance+1.5, h = 2*GelHeight, center = true);
        // 1.5mm is hardcoded as the radius of an M3 screw
        
    }
}
}

//Make the recessed area for the glass slide
translate([0,0,(LidHeight-1)/2]) cube([GelExtLength+8, SlideWidth+lidTolerance,1], center = true);

//Make an open region to see through the slide
cube([GelExtLength+4, SlideWidth-2,LidHeight], center = true);

} //end difference()

}  // end of lid module

module gasketMold(){
    difference(){

        cube([GelExtLength+6.5, GelWidth+6.5, GasketHeight+1], center = true);
      
        //Boolean out the trough
        //2mm hardcoded for gap between gel and trough
    
        difference(){
            translate([0,0,.5])cube([GelExtLength+2+TroughWidth*2, GelWidth+2+TroughWidth*2, GasketHeight], true);
    
            translate([0,0,.5])cube([GelExtLength+2, GelWidth+2, GasketHeight], true);
        } 
   }
} //end of gasket mold module

///////////////
//Below here are modules which encode features of the chambers
///////////////

module makeBody(){
    
    translate([0,0,(ChamberHeightOffset-SolidBottom)/2]) linear_extrude(height = GelHeight+SolidBottom+ChamberHeightOffset, center = true){
        
            offset(OffsetRad) offset(-OffsetRad){
                square([GelExtLength+InOutThick, SlideWidth+SpaceforScrews], true);
            }
        }
}


module fins(){
    
    for (i = [0,1]){
    
        hull(){
            
        mirror([0,i,0]) translate([-GelExtLength/2, (SlideWidth+SpaceforScrews)/2, -GelHeight/2-SolidBottom]) cube([GelExtLength, 1, 2], center = false);
            
        mirror([0,i,0]) translate([GelExtLength/2-5, SpaceforScrews+SlideWidth/2 + 3, -GelHeight/2-SolidBottom]) cylinder(r=5,h=2, center = false);
            
        mirror([0,i,0]) mirror([1,0,0]) translate([GelExtLength/2-5, SpaceforScrews+SlideWidth/2 + 3, -GelHeight/2-SolidBottom]) cylinder(r=5,h=2, center = false);
        }
    }    
}

module createPort(in){
    
    zRot = in[0]; horzShift = in[1]; vertShift = in[2]; axialDist = in[3]; needleGauge = in[4]; mir = in[5]; 
    
    
    translate([abs(sin(zRot))*horzShift-cos(zRot)*(GelExtLength/2+axialDist),abs(cos(zRot))*horzShift-sin(zRot)*(GelWidth/2+axialDist),vertShift]) rotate([0,0,zRot+90]) import(str(needleGauge, "GATip.stl"));
    
    
    if (mir == 1){
        mirror([abs(cos(zRot)), abs(sin(zRot)), 0]) translate([abs(sin(zRot))*horzShift-cos(zRot)*(GelExtLength/2+axialDist),abs(cos(zRot))*horzShift-sin(zRot)*(GelWidth/2+axialDist),vertShift]) rotate([0,0,zRot+90]) import(str(needleGauge, "GATip.stl"));
    }

    else if (mir == 2){
        mirror([1, 0, 0]) mirror([0, 1, 0]) translate([abs(sin(zRot))*horzShift-cos(zRot)*(GelExtLength/2+axialDist),abs(cos(zRot))*horzShift-sin(zRot)*(GelWidth/2+axialDist),vertShift]) rotate([0,0,zRot+90]) import(str(needleGauge, "GATip.stl"));
    }

    else if (mir == 3){
        mirror([1, 0, 0]) mirror([0, 1, 0]) mirror([0,0,1]) translate([abs(sin(zRot))*horzShift-cos(zRot)*(GelExtLength/2+axialDist),abs(cos(zRot))*horzShift-sin(zRot)*(GelWidth/2+axialDist),vertShift]) rotate([0,0,zRot+90]) import(str(needleGauge, "GATip.stl"));
    }
    
    if (NeedlePDMS == 1){
        
        NeedleGask(in);
        
        if (mir == 1){
            mirror([abs(cos(zRot)), abs(sin(zRot)), 0]) NeedleGask(in);
        }
        
        if (mir == 2 || mir == 3){
            mirror([1, 0, 0]) mirror([0, 1, 0]) NeedleGask(in);
        }
        
    }
}

module NeedleGask(in){
     
    zRot = in[0]; horzShift = in[1]; vertShift = in[2]; axialDist = in[3]; needleGauge = in[4]; mir = in[5]; 
    
    translate([abs(sin(zRot))*horzShift-cos(zRot)*(GelExtLength/2+NeedleGaskDist),abs(cos(zRot))*horzShift-sin(zRot)*(GelWidth/2+NeedleGaskDist),-GelHeight/4-SolidBottom/2-.3]) rotate([0,0,zRot+90]) cube([NeedleGaskWidth,1.5,(2/3)*GelHeight+vertShift+SolidBottom+1.7], true);
           
}


module PDMSTraps(){
    
    difference(){
        
        union(){
    
            //SurfaceCavity
            difference() {
                translate([0,0,.5-GelHeight/2]) cube([GelExtLength+6, GelWidth+6, 1], true);
                translate([0,0,.5-GelHeight/2]) cube([GelExtLength+3, GelWidth+3, 1], true);
            }
        
    
            //Subsurface Trap
            difference() {
                translate([0,0,1-GelHeight/2]) cube([GelExtLength+7,GelWidth+8, 1], true);
                translate([0,0,1-GelHeight/2]) cube([GelExtLength+2,GelWidth+2, 1], true);
            }
            
        }
        
        for(i = [0 : len(PortsVector)-1]){
            zRot = PortsVector[i][0];
            mir = PortsVector[i][5];

            translate([0,0,-1]) trapBlock(PortsVector[i]);
    
            if (mir == 1){
                mirror([abs(cos(zRot)), abs(sin(zRot)), 0]) translate([0,0,-1]) trapBlock(PortsVector[i]);
 
            }
            
            else if (mir == 2){
                mirror([1, 0, 0]) mirror([0, 1, 0]) translate([0,0,-1]) trapBlock(PortsVector[i]);
            }
            
            else if (mir == 3){
                mirror([1, 0, 0]) mirror([0, 1, 0]) mirror([0,0,1]) translate([0,0,-1]) trapBlock(PortsVector[i]);
            }
            
        }
    }
}

module trapBlock(in){
    
    zRot = in[0]; horzShift = in[1]; vertShift = in[2]; axialDist = in[3]; needleGauge = in[4]; mir = in[5]; 
        
    translate([abs(sin(zRot))*horzShift-cos(zRot)*(GelExtLength/2+axialDist),abs(cos(zRot))*horzShift-sin(zRot)*(GelWidth/2+axialDist),vertShift]) rotate([0,0,zRot+90]) cube([3,27,3], true);
    
    translate([abs(sin(zRot))*horzShift-cos(zRot)*(GelExtLength/2+axialDist+NeedleGaskDist+1),abs(cos(zRot))*horzShift-sin(zRot)*(GelWidth/2+axialDist+NeedleGaskDist+2),vertShift]) rotate([0,0,zRot+90]) cube([7,27,3], true);
}



module screwsAndNuts(){
   
   //Make holes for screws and traps for hex nuts

    
    if(ExtraScrews == 0){
        for (xScrewDir = [-1, 1]){
            for(yScrewDir = [-1, 1]){
                    
            translate([xScrewDir*(xScrewOffset+GelExtLength/2), yScrewDir*(yScrewOffset+SlideWidth/2), 0]) cylinder(r = screwNutTolerance+1.5, h = 20*GelHeight, center = true);
                // 1.5mm is hardcoded as the radius of an M3 screw
         
            
            translate([xScrewDir*(xScrewOffset+GelExtLength/2), yScrewDir*(yScrewOffset+SlideWidth/2), -GelHeight/2]) cylinder($fn=6, r = (screwNutTolerance+.1)+(5.6/2), h = 3, center = true);
                //This is not actually a cylinder ($fn=6 makes 6 sided polygon)
                //5.6 is hardcoded as the distance across an M3 hex nut   
            }
        }
    }
    
    if(ExtraScrews == 1){
        for (xScrewDir = [-1, 0, 1]){
            for(yScrewDir = [-1, 1]){
                    
            translate([xScrewDir*(xScrewOffset+GelExtLength/2), yScrewDir*(yScrewOffset+SlideWidth/2), 0]) cylinder(r = screwNutTolerance+1.5, h = 2*GelHeight, center = true);
                // 1.5mm is hardcoded as the radius of an M3 screw
            
            translate([xScrewDir*(xScrewOffset+GelExtLength/2), yScrewDir*(yScrewOffset+SlideWidth/2), -GelHeight/2]) cylinder($fn=6, r = (screwNutTolerance+.1)+(5.6/2), h = 3, center = true);
                //This is not actually a cylinder ($fn=6 makes 6 sided polygon)
                //5.6 is hardcoded as the distance across an M3 hex nut              
            }
    }
    } 

}


module labelText(){
   translate([2-xScrewOffset-GelExtLength/2, -yScrewOffset-SlideWidth/2, GelHeight/2-1+ChamberHeightOffset]){
       linear_extrude(1){
           text(nameText2, size = textSize, font="Helvetica:style=Bold");
       }
   }
   translate([2-xScrewOffset-GelExtLength/2, -textSize+yScrewOffset+SlideWidth/2, GelHeight/2-1+ChamberHeightOffset]){
       linear_extrude(1){
           text(nameText1, size = textSize, font="Helvetica:style=Bold");
       }
   }
} 

//
