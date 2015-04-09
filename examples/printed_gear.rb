#!/usr/bin/ruby1.9.3
require "rubygems"
require "crystalscad"
include CrystalScad


g1 = PrintedGear.new(module:2.0,teeth:40,bore:5,height:4)
g2 = PrintedGear.new(module:2.0,teeth:20,bore:5,height:4,rotation:0.5) # rotation in number of teeth

res = g1.show.color("red").rotate(z:"$t*360")
res += g2.show.rotate(z:"-$t*360*#{g1.ratio(g2)}").translate(x:g1.distance_to(g2))

res.save("printed_gear.scad")

