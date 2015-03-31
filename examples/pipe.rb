#!/usr/bin/ruby1.9.3
require "rubygems"
require "crystalscad"
include CrystalScad


class MyPipe < CrystalScad::Pipe
	def shape
		@line_rotation = 30
		return circle(d:@diameter,fn:6)
	end	

	def inner_shape
		circle(d:6)
	end
end

pipe = MyPipe.new(diameter:10)

pipe.line(10)
pipe.ccw(20,30,"yellow")
pipe.line(30)

pipe.cw(30,60,"blue")
pipe.ccw(30,45,"green")
pipe.line(3)
pipe.ccw(30,160,"blue")
pipe.ccw(30,60,"pink")


#pipe.cw(30,60,"blue")
#pipe.cw(20,60,"green")
#pipe.cw(10,60,"black")
#pipe.line(33)
#pipe.cw(30,90,"white")
#pipe.cw(15,95,"silver")
#pipe.line(10,"pink")
res = pipe.pipe

res.save("pipe.scad","$fn=64;")

