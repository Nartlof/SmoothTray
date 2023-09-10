/*
*Author: Eduardo Foltran
*All dimensions are in mm
*Date: 2023-09-05
*Version: 1.0 - Initial design
*License: Creative Commons CC-BY (Attribution)
*/

//Deepth of the tray
Deepth = 40;

//Width of the module
ModuleWidth = 80;

//Length of the module
ModuleLength = 250.5;

//Define the radius for smoothing corners
FilletRadius = 7;

//Define the inclination for walls. 1:3 is the default
Inclination = 3.7;

//The thickness of the walls
WallThickness = 7;

//setting up resolution
$fa=($preview)?$fa:3;
$fs=($preview)?$fs:.5;


module Tray(deepth = Deepth, filletRadiusP=FilletRadius,inclination=Inclination,wallThickness=WallThickness,moduleWidth=ModuleWidth,moduleLength=ModuleLength){
    filletRadius = (filletRadiusP<=WallThickness)?filletRadiusP:WallThickness;
    //Calculating the angle of the lateral walls
    inclAngle = atan(1/inclination);    
    //Calculating the heigth where the straigth wall starts after the curve
    startY = filletRadius * sin(inclAngle);
    startX = filletRadius * cos(inclAngle);
    //Calculating the height of the straigth part of the wall
    straigthDeepth = deepth -2*filletRadius + 2*startY ;
    lengthX = 2*startX+straigthDeepth/inclination;
    difference(){
        OutTray();
        translate([0,0,wallThickness])
        InTray();
    }

    module OutTray(){
        hull(){
            translate([0,0,deepth])
            cube([moduleWidth,moduleLength,2*wallThickness]);
            translate([deepth/inclination,deepth/inclination,0])
            cube([moduleWidth-2*deepth/inclination,moduleLength-2*deepth/inclination,1]);
        }
    }

    module InTray(){
        module innerProfile(){
            translate([0,filletRadius]){
                difference(){
                    union(){
                        //Botton circle
                        difference(){
                        circle(r=filletRadius);
                        translate([-filletRadius,-filletRadius])
                            square([filletRadius,2*filletRadius]);
                        }
                        // Creating the lateral triangle for the profile
                        translate([startX,-startY])
                        polygon([[0,0],[straigthDeepth/inclination,straigthDeepth],[0,straigthDeepth]]);
                        //Filling the left part with a rectangle
                        square([filletRadius,deepth-filletRadius]);
                        //Filling the top part
                        translate([0,straigthDeepth-startY]){
                            square([lengthX, filletRadius*(1-sin(inclAngle))]);
                            translate([0,filletRadius*(1-sin(inclAngle))])
                                square([lengthX+wallThickness, wallThickness]);
                        }
                    }
                    //Cutting out the top circle
                    translate([lengthX,-2*startY+straigthDeepth])
                    circle(r=filletRadius);
                }
            }
        }

        module smoothBlock(width=100){
            squareWidth = width-2*lengthX;
            translate([lengthX,0,0]){
                rotate([0,180,0])
                    innerProfile();
                translate([squareWidth,0])
                    innerProfile();
                square([squareWidth,deepth+wallThickness]);
            }
        }

        //Calculating how much to shrink the inner part to make the thickness of the wall constant.
        blockLength = moduleLength-2*lengthX;
        blockWidth = moduleWidth-2*lengthX;
        translate([0,blockLength+lengthX,0])
            rotate([90,0,0])
                linear_extrude(height=blockLength,convexity=10)
                    smoothBlock(width=moduleWidth);
        translate([lengthX,0,0])
            rotate([90, 0, 90])             
                linear_extrude(height=blockWidth,convexity=10)
                    smoothBlock(width=moduleLength);
        //Placing the corners
        for (i=[0,blockWidth]){
            for (j=[0,blockLength]){
                translate([i+lengthX,j+lengthX]){
                    rotate_extrude(convexity=10)
                        innerProfile();
                }
            }
        }
        //Topping
        translate([-1,-1,deepth])
            cube([moduleWidth+2,moduleLength+2,wallThickness+1]);
    }

}







/*
projection(cut=true)
translate([0,0,-ModuleLength/2])
rotate([90,0,0])*/
Tray();

InclAngle = atan(1/Inclination);
echo(str("Angle = ", InclAngle));
PrintingHeigth = ModuleLength * cos(InclAngle);
echo(str("Heigth = ", PrintingHeigth));
echo(str("Inclination = ", Inclination));