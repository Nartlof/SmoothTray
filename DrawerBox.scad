/*
*Author: Eduardo Foltran
*All dimensions are in mm
*Date: 2023-09-05
*Version: 1.0 - Initial design
*License: Creative Commons CC-BY (Attribution)
*/

//Deepth of the tray
Deepth = 50;

//Width of the module
ModuleWidth = 85;

//Length of the module
ModuleLength = 250;

//Define the radius for smoothing corners
FilletRadiusImposed = 7;

//Define the inclination for walls. 1:3 is the default
Inclination = 3;

//The thickness of the walls
WallThickness = 7;

//setting up resolution
$fa=($preview)?$fa:1;
$fs=($preview)?$fs:.2;

FilletRadius = (FilletRadiusImposed<=WallThickness)?FilletRadiusImposed:WallThickness;


module innerProfile(deepth = Deepth, filletRadius=FilletRadius,inclination=Inclination,wallThickness=WallThickness){
    //Calculating the angle of the lateral walls
    inclAngle = atan(1/inclination);    
    //Calculating the heigth where the straigth wall starts after the curve
    startY = filletRadius * sin(inclAngle);
    startX = filletRadius * cos(inclAngle);
    //Calculating the height of the straigth part of the wall
    straigthDeepth = deepth -2*filletRadius + 2*startY ;
    lengthX = 2*startX+straigthDeepth/inclination;
    rotate_extrude(){
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
                    square([filletRadius,deepth-filletRadius]);
                    translate([0,straigthDeepth-startY]){
                        square([lengthX, filletRadius*(1-sin(inclAngle))]);
                        translate([0,filletRadius*(1-sin(inclAngle))])
                            square([lengthX+wallThickness, wallThickness]);
                    }
                }
                //Top circle
                translate([lengthX,-2*startY+straigthDeepth])
                circle(r=filletRadius);
            }
        }
    }
}

module InTray(deepth = Deepth, filletRadius=FilletRadius,inclination=Inclination,wallThickness=WallThickness,moduleWidth=ModuleWidth,moduleLength=ModuleLength){
    //Calculating the angle of the lateral walls
    inclAngle = atan(1/inclination);    
    //Calculating the heigth where the straigth wall starts after the curve
    startY = filletRadius * sin(inclAngle);
    startX = filletRadius * cos(inclAngle);
    //Calculating the height of the straigth part of the wall
    straigthDeepth = deepth - filletRadius * sin(inclAngle)- filletRadius;
    lengthX = 2*startX+straigthDeepth/inclination;
    translate([-1,-1,deepth])
    cube([moduleWidth+2,moduleLength+2,wallThickness+1]);
    translate([lengthX,lengthX,0]){
        minkowski(){
            cube([moduleWidth-2*lengthX,moduleLength-2*lengthX,1]);
            innerProfile(deepth = Deepth, filletRadius=FilletRadius,inclination=Inclination,wallThickness=WallThickness);
        }
    }    
}


module OutTray(deepth = Deepth, filletRadius=FilletRadius,inclination=Inclination,wallThickness=WallThickness,moduleWidth=ModuleWidth,moduleLength=ModuleLength){
    //Calculating the angle of the lateral walls
    inclAngle = atan(1/inclination);    
    //Calculating the heigth where the straigth wall starts after the curve
    startY = filletRadius * sin(inclAngle);
    startX = filletRadius * cos(inclAngle);
    //Calculating the height of the straigth part of the wall
    straigthDeepth = deepth - filletRadius * sin(inclAngle)- filletRadius;
    lengthX = 2*startX+straigthDeepth/inclination;
    hull(){
        translate([0,0,deepth])
        cube([moduleWidth,moduleLength,2*wallThickness]);
        translate([deepth/inclination,deepth/inclination,0])
        cube([moduleWidth-2*deepth/inclination,moduleLength-2*deepth/inclination,1]);
    }
}

module Tray(){
    difference(){
        OutTray();
        translate([0,0,WallThickness])
        InTray();
    }
}
/*
projection(cut=true)
translate([0,0,-ModuleLength/2])
rotate([90,0,0])*/
Tray();
