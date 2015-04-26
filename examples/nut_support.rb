#!/usr/bin/ruby1.9.3
require "rubygems"
require "crystalscad"
include CrystalScad




res = cube([160,20,20]).center_y.translate(x:-5)
[2.5,3,4,5,6,8,10,12].each do |size|
	b = Bolt.new(size,40)
	n = Nut.new(size)
	res -= b.output
	res -= n.output	
	res += n.add_support(0.2)

	res.translate(x:-20)
end




res.save("nut_support.scad","$fn=64;")

