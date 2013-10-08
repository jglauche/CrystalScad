CrystalScad
===========

CrystalScad is a framework for programming 2d and 3d OpenScad models in Ruby. 

Installation:
===========
Dependencies:
- Ruby 1.9.3
- inotifywait
- gem rubyscad
- gem requireall

Install via gem:

# gem install crystalscad

if you have multiple ruby versions, you likely need to use gem1.9.3 instead of gem

Install via git:
rake build
gem install pkg/crystalscad-<version>.gem


Coding
===========
Chain transformations:
  res = cube([1,2,3]).rotate(x:90).translate(x:20,y:2,z:1).mirror(z:1)

CSG Modeling:
  res = cylinder(d:10,h:10)
  # union
  res += cube(x:5,y:20,z:20)
  # difference
  res -= cylinder(d:5,h:10)
  # intersection
  res *= cylinder(d:10,h:10)
  
Hull:
  res = hull(cylinder(d:10,h:10),cube([20,10,10].translate(x:10)))

Center cubes in X/Y direction only:
  cube([10,10,10]).center_xy # note: does only work on cubes and must be put before any transformations

Also implemented: center_x, center_y, center_z  
  

Long slots:   
  # produces a hull of two cylinders, 14mm apart
  long_slot(d:4.4,h:10,l:14)  
  




Framework Usage
===========
An example project skeleton is located in the skeleton_project directory. Try it out:

cd skeleton_project
./observe.sh 
open skeleton.rb in an editor and skeleton.scad in OpenScad to play with it.

use ./skeleton.rb build to build all parts (specify all printed part in the Array parts in skeleton.rb)

To get started with your own project, rename skeleton_project/ and skeleton.rb to the name of your choice.
A few tips:
- Be visual. Put your desired situation on the screen, then model your object around it
- Make assemblies. An Assembly can be either a part that you need to print out or a set of parts that go together. 
- When porting OpenScad code, beware of dividing integers. Example: 
  cylinder(r=11/2,h=10);
  needs to be ported to
  cylinder(r:11.0/2,h:10)
  or
  cylidner(d:11,h:10)
  





Real World Example:
===========
https://github.com/Joaz/bulldozer/blob/master/



License:
===========
GPLv3

