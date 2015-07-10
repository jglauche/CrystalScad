#!/usr/bin/ruby1.9.3
require "rubygems"
require "crystalscad"
include CrystalScad

# Note that this example does not work as intended and the function is deprecated

parts = [ 
			Washer.new(4.3),
			Nut.new(4),		
			Washer.new(4.3),
			Nut.new(4)		
		]
bolt = Bolt.new(4,16).show
bolt_assembly = bolt
bolt_assembly += stack({method:"output",spacing:0.1}, *parts)

x,y,z = position(bolt)
bolt_assembly.translate(x:x*-1,y:y*-1,z:z*-1)

bolt_assembly.save("stack.scad")


