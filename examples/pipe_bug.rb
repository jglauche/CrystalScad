#!/usr/bin/ruby1.9.3
require "rubygems"
require "crystalscad"
include CrystalScad

# Used to debug
# https://github.com/jglauche/CrystalScad/issues/5

pipe = Pipe.new(diameter:10)

pipe.line(5,"red")
pipe.cw(20,8,"yellow")
pipe.line(20,"blue")

	
	
res = pipe.pipe

res.save("pipe_bug.scad","$fn=64;")




