#!/usr/bin/ruby1.9.3
require "rubygems"
require "crystalscad"
include CrystalScad

# note that center:true doesn't work with cube
# however, there are convenience methods like 
# center, center_x, center_y, center_xy, center_z available.
# As rule of thumb, avoid center if possible.

res1 = cube([30,30,30]).center
res1+= cube([15,15,50]).center.translate(z:-25)

res2 = cube([50,10,10]).center
res2+= cube([10,50,10]).center
res2+= cube([10,10,50]).center

res = res1-res2
res*=cylinder(r1:20,r2:5,h:50,center:true).translate(z:5)

res.save("example002.scad")





=begin
module example002()
{
	intersection() {
		difference() {
			union() {
				cube([30, 30, 30], center = true);
				translate([0, 0, -25])
					cube([15, 15, 50], center = true);
			}
			union() {
				cube([50, 10, 10], center = true);
				cube([10, 50, 10], center = true);
				cube([10, 10, 50], center = true);
			}
		}
		translate([0, 0, 5])
			cylinder(h = 50, r1 = 20, r2 = 5, center = true);
	}
}

example002();
=end


