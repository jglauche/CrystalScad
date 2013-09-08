CrystalScad
===========

Produce OpenSCAD code in Ruby. Based on RubyScad

Requires Ruby 1.9.3

Currently not feature complete



Example Code:


require "crystalscad"

include CrystalScad

res = cylinder(r:5,h:10).translate(x:10).rotate(y:45)
res+= cube([10,20,30])
res-= cube([5,10,40]).translate(z:-1)

puts res.output



