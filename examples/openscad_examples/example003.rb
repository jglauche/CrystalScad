#!/usr/bin/ruby1.9.3
require "rubygems"
require "crystalscad"
include CrystalScad


def example003
  res1 = cube([30,30,30]).center
  res2 = nil # either initialize it with a CrystalScadObject or nil as we do a += on it later on
  [[1,0,0],[0,1,0],[0,0,1]].each do |x,y,z| 
    res1+= cube([15+x*25,15+y*25,15+z*25]).center
    res2+= cube([10+x*40,10+y*40,+10+z*40]).center
  end
  res1-res2  
end

example003.save("example003.scad")


=begin

module example003()
{
	difference() {
		union() {
			cube([30, 30, 30], center = true);
			cube([40, 15, 15], center = true);
			cube([15, 40, 15], center = true);
			cube([15, 15, 40], center = true);
		}
		union() {
			cube([50, 10, 10], center = true);
			cube([10, 50, 10], center = true);
			cube([10, 10, 50], center = true);
		}
	}
}

example003();

=end

