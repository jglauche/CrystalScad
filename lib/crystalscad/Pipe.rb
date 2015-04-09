#    This file is part of CrystalScad.
#
#    CrystalScad is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    CrystalScad is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with CrystalScad.  If not, see <http://www.gnu.org/licenses/>.



module CrystalScad
	class Pipe
		attr_accessor :x,:y, :sum_x, :sum_y, :pipe
		# Warning: sum_x and sum_y are both a quick hack at the moment
		# 				 They will ONLY work on bends if you do same thing in the other direction 
		#					 for example 
		#					 pipe.cw(20,30)
		#					 pipe.ccw(20,30)
		#	This might be fixed in the future.

		def radians(a)
		  a/180.0 * Math::PI
		end

		def initialize(args={})
			# parameters
			@diameter = args[:diameter] || 1
			@fn = args[:fn] || 64
			@line_rotation = args[:line_rotation] || 0 # z rotation in case needed with fn values

			# variable initialization
			@pipe = nil	
			@sum_x = 0
			@sum_y = 0
		end

		def shape
			res = circle(d:@diameter,fn:@fn)
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
				@pipe = bent_cw(radius,angle)	
				@pipe = @pipe.color(color) unless color == nil
			else
				rotated_pipe = @pipe.rotate(z:-angle)	
				pipe_piece = bent_cw(radius,angle)
				pipe_piece = pipe_piece.color(color) unless color == nil
				@pipe = pipe_piece + rotated_pipe.translate(x:x,y:y-radius)
			end	
		end

		# go counter clockwise
		def ccw(radius,angle,color=nil)
			if angle > 360
				return false		
			end		
			# since bent can only do up to 90°, splitting it up in chunks in order to grow it 
			if angle > 90
				return ccw(radius,90,color) + ccw(radius,angle-90,color)	
			end

			if @pipe == nil
				@pipe = bent_ccw(radius,angle)	
				@pipe = @pipe.color(color) unless color == nil
			else
				rotated_pipe = @pipe.rotate(z:angle)	
				pipe_piece = bent_ccw(radius,angle)
				pipe_piece = pipe_piece.color(color) unless color == nil
				@pipe = pipe_piece + rotated_pipe.translate(x:x,y:y+radius)
			end	
	
		end

		def line(length,color=nil)
			if @pipe == nil
				@pipe = create_line(length,color) 
			else
				@pipe = @pipe.translate(x:length) + create_line(length,color)				
			end
			@sum_x += length
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
	
		def bent_cw(radius,angle)	
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
	
			@sum_x += @x
			@sum_y += @y	

			res *= cut.linear_extrude(h:100).translate(z:-50)
		
			# Positioning it on 0 
		
			return res.translate(y:-radius)
		end

		def bent_ccw(radius,angle)	
			res = shape.translate(x:radius).rotate_extrude(convexity:10)
			res -= inner_shape.translate(x:radius).rotate_extrude(convexity:10) unless inner_shape == nil

			len = radius+@diameter/2.0
			@x = Math::sin(radians(angle))*len
			@y = Math::cos(radians(angle))*len
			cut = polygon(points:[[0,0],[0,len],[@x,@y]]).scale(2)
		
			# for working with it
			len = radius #- @diameter / 2.0
			@x = Math::sin(radians(angle))*len
			@y = -1*Math::cos(radians(angle))*len
	
			@sum_x += @x
			@sum_y += @y	

			res *= cut.linear_extrude(h:100).translate(z:-50)
			res = res.mirror(y:1)	
			# Positioning it on 0 
		
			return res.translate(y:radius)
		end


	end
end

