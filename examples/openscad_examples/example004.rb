#!/usr/bin/ruby1.9.3
require "rubygems"
require "crystalscad"
include CrystalScad


def example004
  cube([30,30,30]).center-sphere(d:40)
end

example004.save("example004.scad")


=begin


module example004()
{
	difference() {
		cube(30, center = true);
		sphere(20);
	}
}

example004();


=end

