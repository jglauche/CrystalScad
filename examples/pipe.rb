#!/usr/bin/ruby1.9.3
require "rubygems"
require "crystalscad"
include CrystalScad


class Pipe
	attr_accessor :x,:y, :pipe
  def radians(a)
    a/180.0 * Math::PI
  end

	def initialize(args={})
		@diameter = args[:diameter]
		@pipe = nil	
		@line_rotation = 0 # z rotation in case needed with fn values
	end

	def shape
		res = circle(d:@diameter)
	end
  
	def inner_shape
		nil
	end
	
	# go clockwise
	def cw(radius,angle,color=nil)
		if angle > 360
			return false		
		end		
		# since bent can only do up to 90°, splitting it up in chunks in order to grow it 
		if angle > 90
			return cw(radius,90,color) + cw(radius,angle-90,color)	
		end

		if @pipe == nil
			@pipe = bent(radius,angle)	
			@pipe = @pipe.color(color) unless color == nil
		else
			rotated_pipe = @pipe.rotate(z:-angle)	
			pipe_piece = bent(radius,angle)
			pipe_piece = pipe_piece.color(color) unless color == nil
			@pipe = pipe_piece + rotated_pipe.translate(x:x,y:y-radius)
		end	
	end

	def line(length,color=nil)
		if @pipe == nil
			@pipe = create_line(length,color) 
		else
			@pipe = @pipe.translate(x:length) + create_line(length,color)				
		end

	end

	private
	def create_line(length,color=nil)
		res = shape.linear_extrude(h:length)
		if inner_shape 
			res -= inner_shape.linear_extrude(h:length+0.2).translate(z:-0.1)
		end
		if color
			res = res.color(color)		
		end
		res.rotate(z:@line_rotation).rotate(y:90)
	end
	
	def bent(radius,angle)	
		res = shape.translate(x:radius).rotate_extrude(convexity:10)
		res -= inner_shape.translate(x:radius).rotate_extrude(convexity:10) unless inner_shape == nil

		len = radius+@diameter/2.0
		@x = Math::sin(radians(angle))*len
		@y = Math::cos(radians(angle))*len
		cut = polygon(points:[[0,0],[0,len],[@x,@y]]).scale(2)
		
		# for working with it
		len = radius #- @diameter / 2.0
		@x = Math::sin(radians(angle))*len
		@y = Math::cos(radians(angle))*len
	

		res *= cut.linear_extrude(h:100).translate(z:-50)
		
		# Positioning it on 0 
		
	  return res.translate(y:-radius)
	end


end

class MyPipe < Pipe
	def shape
		@line_rotation = 30
		return circle(d:@diameter,fn:6)
	end	

	def inner_shape
		circle(d:6)
	end
end

pipe = MyPipe.new(diameter:10)

pipe.cw(30,60,"blue")
pipe.cw(20,60,"green")
pipe.cw(10,60,"black")
pipe.line(33)


pipe.cw(30,90,"white")
pipe.cw(15,95,"silver")
pipe.line(10,"pink")

res = pipe.pipe

res.save("pipe.scad","$fn=64;")

