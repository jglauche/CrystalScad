#!/usr/bin/ruby1.9.3
require "rubygems"
require "crystalscad"
include CrystalScad





res = knurled_cube([4,0.5,7])
#res = knurled_cylinder(d:16,h:10)



res.save("knurls.scad","$fn=64;")

