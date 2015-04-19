#!/usr/bin/ruby1.9.3
require "rubygems"
require "crystalscad"
include CrystalScad




res = knurled_cube([41,10,4])
#Total rendering time: 0 hours, 5 minutes, 53 seconds

#Total rendering time: 0 hours, 1 minutes, 41 seconds

#res = knurled_cylinder(d:16,h:10)



res.save("knurls.scad","$fn=64;")

