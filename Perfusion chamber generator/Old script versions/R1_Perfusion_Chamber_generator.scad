//************************************//
//************************************//
//    Perfusion Chamber Generator     //
//    Ian Kinstlinger, MillerLab      //
//    Updated 9/2/2020               //
//************************************//
//************************************//

//////////////////////////////////////
//Gel dimensions
//////////////////////////////////////

GelLength = 19; //mm
//The script will automatically make the chamber 2mm longer than the gel to give clearance for catheters and repositioning
GelWidth = 9; //mm
GelHeight = 10; //mm

nameText1 = "Hello World";
nameText2 = "Chamber Body";
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

Fins = 0 ; //To mount in a vertical holder
SolidBottom = 0; //Choose no (0) if you need to image through the bottom!
PDMSTraps = 1; //To add features to help with PDMS adhesion for glass slides
//NOTES: if making a solid bottom, PDMS traps should be off (no glass to adhere)
// Currently PDMS traps are not supported if extra screws are used
NeedlePDMS = 1; //Add empty space to create a PDMS gasket for your catheter tips
ExtraScrews = 0;
ExternalGelPorts =  0; //Add extra catheter ports on sides to allow media perfusion through external space on top of gel 


//*************************************
//Parameters you may want to change
//*************************************

InletOutletZOffset = 0; 
//If the inlet and outlet are not at the center of their respective faces of the gel, what is their offset? If lower then center, use a negative offset

NeedleGauge = 18; //Must be 15, 18, or 20!
//By default, all tips assumed to be the same gauge. More options below if not the case

TroughWidth = 2; //How wide is the trough which holds the PDMS gasket?
TroughDepth = 1; //How deep is the trough which holds the PDMS gasket?

xScrewOffset = 8.5; //Spacing screws along gel long side
yScrewOffset = 3; //Spacing screws along gel short side

GasketHeight = 1.5;
LidHeight = 2.5; //mm


//*************************************
//Parameters that should mostly stay the same
//*************************************

ExternalPortZOffset = 3.5; //Position above center for extra catheter ports

ChamberHeightOffset = 0 + ExternalGelPorts*(ExternalPortZOffset+0.5); //Changes the overall height of the chamber without affecting gel chamber placement or dimensions
    //Note: ChamberHeightOffset must be increased (recommended +0.5 of MediaPortZOffset) if using media ports to allow room for needles without interfering with PDMS gasket

GelExtLength = GelLength + 2; //Add 2 mm to give space to maneuver and visualize catheters
InOutThick = 26; //mm //Adjust this to change how much the tip sticks into the gel channel
SpaceforScrews = 18; //mm //Width of solid region where the screws go through
TipBooleanDist = 11; //mm //This controls the gemetry of where the Nordson tip is wedged into the chamber

ExternalPortBooleanDist = 4; // //This controls the gemetry of where the optional external gel tip is wedged into the chamber

ExternalPortNeedleGauge = NeedleGauge; //Change if different gauge tips are used

HullCylRad = 7; //This controls the filleted corner curvature
SlideWidth = 25; //Standard microscope slide is 25mm

textSize = 3;

screwNutTolerance = 0.3;
lidTolerance = 0.25;


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
//

module chamber(){

difference(){
   
union(){
filletCorners();

if(Fins == 1){
    fins();
}
    
}

//Here come all the things are are subtracting from the initial solid block

translate([0,0,ChamberHeightOffset/2]) cube([GelExtLength, GelWidth, GelHeight+ChamberHeightOffset], center = true); //Main gel cavity

booleanCatheterTip(); //Slots for catheter tips
mirror([1,0,0]){booleanCatheterTip();};

//Optional media ports
if(ExternalGelPorts == 1){
translate([.35*GelExtLength,-ExternalPortBooleanDist,0]) booleanMediaPorts(); //Slots for catheter tips for media ports on sides
translate([-.35*GelExtLength,ExternalPortBooleanDist,0]) mirror([0,1,0]){booleanMediaPorts();};

translate([-.35*GelExtLength,0,0]) NeedlePDMSMediaPorts();

translate([.35*GelExtLength,0,0]) mirror([0,1,0]){NeedlePDMSMediaPorts();};


}

//Make the trough for the PDMS gasket
//2mm is hardcoded as the space between the gel chamber and the trough

difference(){
translate([0,0,(GelHeight-TroughDepth)/2+ChamberHeightOffset])cube([GelExtLength+2+TroughWidth*2, GelWidth+2+TroughWidth*2, TroughDepth], center = true);
    
translate([0,0,(GelHeight-TroughDepth)/2+ChamberHeightOffset])cube([GelExtLength+2, GelWidth+2, TroughDepth], center = true);
}



//PDMS traps
if(PDMSTraps == 1){
        PDMSTrap();
    mirror([0,1,0]){PDMSTrap();};
}

//Gaskets for catheters
if(NeedlePDMS == 1){
    NeedlePDMS();
    mirror([1,0,0]){NeedlePDMS();};
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



}

module gasketMold(){
    difference(){

cube([GelExtLength+6.5, GelWidth+6.5, GasketHeight+1], center = true);  

//cube([GelExtLength, GelWidth, GasketHeight+1], center = true);
    //This line can be uncommented if you are curing the PDMS gasket at room temp to print faster
    //But if curing at 60C, you need this inner plastic to prevent the mold from warping
    
//Boolean out the trough
//2mm hardcoded for gap between gel and trough    
    
difference(){
translate([0,0,.5])cube([GelExtLength+2+TroughWidth*2, GelWidth+2+TroughWidth*2, GasketHeight], center = true);
    
translate([0,0,.5])cube([GelExtLength+2, GelWidth+2, GasketHeight], center = true);
}
    
}
    
}
//

module booleanCatheterTip(){
  
  if(NeedleGauge == 15){  
    rotate([0, 0, 90]) translate([0,TipBooleanDist+GelExtLength/2,InletOutletZOffset]) import("15GATip.stl");
    
}  
  
    else if(NeedleGauge == 18){
    
    rotate([0, 0, 90]) translate([0,TipBooleanDist+GelExtLength/2,InletOutletZOffset]) import("18GATip.stl");
  
}

    else if(NeedleGauge == 20){
    
rotate([0, 0, 90]) translate([0,TipBooleanDist+GelExtLength/2,InletOutletZOffset]) import("20GATip.stl");
 
}
    
    else{
    
    echo("Enter a valid needle gauge");
    }
}

module booleanMediaPorts(){
  
  if(ExternalPortNeedleGauge == 15){  
    rotate([0, 0, 180]) translate([0,TipBooleanDist+GelWidth/2,ExternalPortZOffset]) import("15GATip.stl");
    
}  
  
    else if(ExternalPortNeedleGauge == 18){
    
    rotate([0, 0, 180]) translate([0,TipBooleanDist+GelWidth/2,ExternalPortZOffset]) import("18GATip.stl");
  
}

    else if(ExternalPortNeedleGauge == 20){
    
    rotate([0, 0, 180]) translate([0,TipBooleanDist+GelWidth/2,ExternalPortZOffset]) import("20GATip.stl");
 
}
    
    else{
    
    echo("Enter a valid needle gauge");
    }
}


module PDMSTrap(){
   
    translate([0,GelWidth+yScrewOffset/2,1.5-GelHeight/2]) cube([GelExtLength+6,5,1.5], center = true);
    //Subsurface expanded trap to prevent leaks
    
    translate([0,GelWidth+yScrewOffset/2,.5-GelHeight/2]) cube([GelExtLength+3,2,2], center = true);
    //Thinner surface cavity for filling
    
    difference() {
    translate([GelExtLength/2+2,0,.5-GelHeight/2]) cube([1.5,2+2*GelWidth+yScrewOffset,2], center = true);
        //surface cavity
        
    translate([GelExtLength/2+2,0,.5-GelHeight/2]) cube([1.5,4,2], center = true);
    }
    
    difference() {
    translate([-GelExtLength/2-2,0,.5-GelHeight/2]) cube([1.5,2+2*GelWidth+yScrewOffset,2], center = true);
        //surface cavity
        
    translate([-GelExtLength/2-2,0,.5-GelHeight/2]) cube([1.5,4,2], center = true);
    }
   
        
}    


module NeedlePDMS(){
    
    if(GelHeight < 6){
    
    translate([GelExtLength/2+5,0,-.3]) cube([1.5,5,GelHeight-.3], center = true);
    //Main cavity for PDMS casting
    }
    
    if(GelHeight >= 6){
     
    translate([GelExtLength/2+5,0,-2]) cube([1.5,6,GelHeight-2], center = true);
    //Main cavity for PDMS casting
    
     
    translate([GelExtLength/2+5,0,0]) cube([4,8,3], center = true);
    //Sub-surface expanded trap to prevent leaks
    }
    
}

module NeedlePDMSMediaPorts(){
    
    if(GelHeight+ChamberHeightOffset < 5){
    
    translate([0,GelWidth+yScrewOffset/2,-.3]) cube([6,2,GelHeight+ChamberHeightOffset-.3], center = true);
    //Main cavity for PDMS casting
    }
    
    if(NeedlePDMS == 1){
    
    if(GelHeight+ChamberHeightOffset >= 5){
     
    translate([0,GelWidth+yScrewOffset/2,ChamberHeightOffset/2-.3]) cube([6,2,GelHeight+ChamberHeightOffset-.3], center = true);
    //Main cavity for PDMS casting
    
     
    translate([0,GelWidth+yScrewOffset/2,ChamberHeightOffset/2]) cube([8,4,1.5], center = true);
    //Sub-surface expanded trap to prevent leaks
    }
}
    
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
module filletCorners(){
    
    //Fillet the corners of the chamber to use less material, print faster, look cooler



hull(){
    translate([InOutThick/2+GelExtLength/2-HullCylRad, (SlideWidth+SpaceforScrews)/2-HullCylRad, (ChamberHeightOffset-SolidBottom)/2]) cylinder(r=HullCylRad, h=GelHeight+SolidBottom+ChamberHeightOffset, center = true);
    translate([-InOutThick/2-GelExtLength/2+HullCylRad, (SlideWidth+SpaceforScrews)/2-HullCylRad, (ChamberHeightOffset-SolidBottom)/2]) cylinder(r=HullCylRad, h=GelHeight+SolidBottom+ChamberHeightOffset, center = true); 
    translate([InOutThick/2+GelExtLength/2-HullCylRad, -(SlideWidth+SpaceforScrews)/2+HullCylRad, (ChamberHeightOffset-SolidBottom)/2]) cylinder(r=HullCylRad, h=GelHeight+SolidBottom+ChamberHeightOffset, center = true);
    translate([-InOutThick/2-GelExtLength/2+HullCylRad, -(SlideWidth+SpaceforScrews)/2+HullCylRad, (ChamberHeightOffset-SolidBottom)/2]) cylinder(r=HullCylRad, h=GelHeight+SolidBottom+ChamberHeightOffset, center = true); 
    
}


    
}
module fins(){
    
        for (i = [0,1]){
    
    hull(){
        
    mirror([0,i,0]) translate([-GelExtLength/2, (SlideWidth+SpaceforScrews)/2, -GelHeight/2-SolidBottom])  cube([GelExtLength, 1, 2], center = false);
        
    mirror([0,i,0]) translate([GelExtLength/2-5, SpaceforScrews+SlideWidth/2 + 3, -GelHeight/2-SolidBottom]) cylinder(r=5,h=2, center = false);
        
    mirror([0,i,0]) mirror([1,0,0]) translate([GelExtLength/2-5, SpaceforScrews+SlideWidth/2 + 3, -GelHeight/2-SolidBottom]) cylinder(r=5,h=2, center = false);
    }
        
    }
     
}


module labelText(){
   translate([4-xScrewOffset-GelExtLength/2, -2-yScrewOffset-SlideWidth/2, GelHeight/2-1+ChamberHeightOffset]){
       linear_extrude(1){
           text(nameText2, size = textSize, font=       "Helvetica:style=Bold");
       }
   }
   translate([4-xScrewOffset-GelExtLength/2, -2+yScrewOffset+SlideWidth/2, GelHeight/2-1+ChamberHeightOffset]){
       linear_extrude(1){
           text(nameText1, size = textSize, font=       "Helvetica:style=Bold");
       }
   }
} 


//



