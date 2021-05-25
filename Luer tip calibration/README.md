### Luer tip calibration

In the perfusion chamber generator, we provide STL files named 15GATip, 18GATip, etc, which OpenSCAD will use to Boolean subtract a cavity for the physical Luer tip to slide into the chamber. These STL files were sized empirically based on what fit correctly in our chambers, printed on Prusa i3 printers with 0.15mm layer height. 

If you need different sizes than the defaults provided, or the defaults are not the right size when printed on your printer, you can use this Luer tip gauge to figure out the correct size. 

First, print LuerTipGauge.stl on the same printer and with the same slicing profile as you will use for perfusion chambers. The gauge has slots for different sized Luer tips, from 0.2-2.0 mm in 0.1mm increments. 

Next, once you identity the right size (in mm) for your need, you can find the corresponding STL file in the folder "Tip STLs". That STL file should be **renamed** in the format ##GATip.stl, and copied into the same directory as the chamber generator SCAD script. (If you use filenames not in this format, you will need to change the SCAD file to recognize the new name). 
