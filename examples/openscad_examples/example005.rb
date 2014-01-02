#!/usr/bin/ruby1.9.3
require "rubygems"
require "crystalscad"
include CrystalScad


# note that openscad works with radians automatically and ruby doesn't.
def radians(a)
  a/180.0 * Math::PI
end

def example005
  # base 
  res = cylinder(d:200,h:50)
  res -= cylinder(d:160,h:50).translate(z:10)
  res -= cube([50,50,50]).center.translate(x:100,z:35)   
  
  # pylons
  (0..5).each do |i|
    res+= cylinder(d:20,h:200).translate(x:Math::sin(radians(360*i/6))*80,y:Math::cos(radians(360*i/6))*80) 
  end

  # roof
  res += cylinder(d1:240,d2:0,h:80).translate(z:200)  
  
  res.translate(z:-120)
end

example005.save("example005.scad")


=begin



module example005()
{
	translate([0, 0, -120]) {
		difference() {
			cylinder(h = 50, r = 100);
			translate([0, 0, 10]) cylinder(h = 50, r = 80);
			translate([100, 0, 35]) cube(50, center = true);
		}
		for (i = [0:5]) {
			echo(360*i/6, sin(360*i/6)*80, cos(360*i/6)*80);
			translate([sin(360*i/6)*80, cos(360*i/6)*80, 0 ])
				cylinder(h = 200, r=10);
		}
		translate([0, 0, 200])
			cylinder(h = 80, r1 = 120, r2 = 0);
	}
}

example005();


=end

