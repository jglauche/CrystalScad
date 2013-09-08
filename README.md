CrystalScad
===========

Produce OpenSCAD code in Ruby. Based on RubyScad

Requires Ruby 1.9.3

Currently not feature complete


Features
===========
- Write Models/Assemblies for OpenScad in Ruby
- Automatic BOM when using the Hardware lib


Example Code:
===========

require "crystalscad"

include CrystalScad

assembly = cylinder(r:5,h:10).translate(x:10).rotate(y:45)

assembly+= cube([10,20,30]).translate(x:-1)

assembly-= Bolt.new(3,25).output.translate(x:2,y:2)

assembly-= Bolt.new(3,25).output.translate(x:6,y:6)


# for openscad output
puts assembly.output


# for BOM output
puts @@bom.output



License:
===========
GPLv3

