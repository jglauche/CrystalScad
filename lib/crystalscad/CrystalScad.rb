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

require "rubygems"
require "rubyscad"

module CrystalScad 
	include CrystalScad::BillOfMaterial
	include CrystalScad::Hardware
	include CrystalScad::LinearBearing
	
	
	class CrystalScadObject
		attr_accessor :args		
    attr_accessor :transformations
		def initialize(*args)
			@transformations = []
			@args = args.flatten
			if @args[0].kind_of? Hash
				@args = @args[0]			
			end		
		end		


		def walk_tree
			res = ""			
			
			@transformations.reverse.each{|trans|
				res += trans.walk_tree 
			}
			res += self.to_rubyscad.to_s+ "\n"
			res
		end
		alias :scad_output :walk_tree		
		
		def to_rubyscad
			""
		end
	
	end

	class Primitive < CrystalScadObject
		attr_accessor :children		

		def rotate(args)
		  # always make sure we have a z parameter; otherwise RubyScad will produce a 2-dimensional output
		  # which can result in openscad weirdness
		  if args[:z] == nil
		    args[:z] = 0
		  end
			@transformations << Rotate.new(args)	
			self
		end

		def translate(args)
			@transformations << Translate.new(args)		
			self			
		end
		
		def union(args)
			@transformations << Union.new(args)		
			self			
		end

		def mirror(args)
			@transformations << Mirror.new(args)		
			self			
		end

  end

	class Transformation < CrystalScadObject
	end

	class Rotate < Transformation
		def to_rubyscad
			return RubyScadBridge.new.rotate(@args)		
		end	
	end

 	class Translate < Transformation
		def to_rubyscad
			return RubyScadBridge.new.translate(@args)		
		end	
	end
	
 	class Mirror < Transformation
		def to_rubyscad
			return RubyScadBridge.new.mirror(@args)		
		end	
	end
	
	
	class Cylinder < Primitive
		def to_rubyscad	
			return RubyScadBridge.new.cylinder(@args)		
		end	
	end

	def cylinder(args)
		Cylinder.new(args)		
	end
	
	class Cube < Primitive
	  attr_accessor :x,:y,:z
	  
	  def initialize(*args)
	    super(args)
	    @x,@y,@z = args[0][:size].map{|l| l.to_f}
	  end
	
		def to_rubyscad
			return RubyScadBridge.new.cube(@args)		
		end	
	end

	def cube(args)
		if args.kind_of? Array
			args = {size:args}
		end	
		Cube.new(args)	
	end

	#	2d primitives
	class Square < Primitive
		def to_rubyscad
			return RubyScadBridge.new.square(@args)		
		end			
	end

	def square(args)
		Square.new(args)	
	end

	class Circle < Primitive
		def to_rubyscad
			return RubyScadBridge.new.circle(@args)		
		end			
	end

	def circle(args)
		Circle.new(args)	
	end

	class Polygon < Primitive
		def to_rubyscad
			return RubyScadBridge.new.polygon(@args)		
		end			
	end

	def polygon(args)
		Polygon.new(args)	
	end

	
	class RubyScadBridge
		include RubyScad

		def raw_output(str)
			return str
		end

		def format_output(str)
			return str
		end

		def format_block(output_str)
			return output_str
		end
	end


	class CSGModelling < Primitive
		def initialize(*list)
			@transformations = []
			@children = list
		end

		def to_rubyscad
			@children ||= []			
			ret = "#{@operation}(){"
			@children.each do |child|	
				begin
					ret +=child.walk_tree
				rescue NoMethodError	
				end
			end
			ret +="}"			
		end
	end	

	class Union < CSGModelling		
		def initialize(*list)
			@operation = "union"
			super(*list)
		end
	end

	class Difference < CSGModelling		
		def initialize(*list)
			@operation = "difference"
			super(*list)
		end
	end

	class Intersection < CSGModelling		
		def initialize(*list)
			@operation = "intersection"
			super(*list)
		end
	end

	class Hull < CSGModelling		
		def initialize(*list)
			@operation = "hull"
			super(*list)
		end
	end


	def +(args)	
		return args	 if self == nil		
		Union.new(self,args)
	end

	def -(args)
		return args	 if self == nil		
		Difference.new(self,args)
	end
	
	def *(args)
		return args	 if self == nil		
		Intersection.new(self,args)
	end
	
	def hull(*parts)
	  Hull.new(*parts)	  
	end

	class CSGModifier < Primitive
		def initialize(object, attributes)
			@transformations = []
			@children = [object]
			@attributes = attributes
		end

		def to_rubyscad		
			ret = "#{@operation}(#{@attributes}){"
			@children ||= []			
			@children.each do |child|	
				begin
					ret +=child.walk_tree
				rescue NoMethodError
				end
			end
			ret +="}"			
		end
	end	

	class Color < CSGModifier
		def initialize(object, attributes)
			@operation = "color"
			if attributes.kind_of? String
				attributes = "\"#{attributes}\""			
			elsif attributes.kind_of? Hash
				# FIXME
			end
			
			super(object, attributes)
		end
	end
	
	class LinearExtrude < CSGModifier
		def initialize(object, attributes)
			@operation = "linear_extrude"
			super(object, attributes)
		end
	end

	class RotateExtrude < CSGModifier
		def initialize(object, attributes)
			@operation = "rotate_extrude"
			super(object, attributes)
		end
	end
	
	def color(args)
		return Color.new(self,args)		
	end

	def linear_extrude(args)
		args = args.collect { |k, v| "#{k} = #{v}" }.join(', ')
		return LinearExtrude.new(self,args)				
	end

	def rotate_extrude(args)
		args = args.collect { |k, v| "#{k} = #{v}" }.join(', ')
		return RotateExtrude.new(self,args)				
	end
	

	#	Stacks parts along the Z axis
	# works on all Assemblies that have a @height definition
	def stack(args={}, *parts)
		args[:method] ||= "show"
		args[:additional_spacing] ||= 0
		@assembly = nil		
		z = 0
		parts.each do |part|
			@assembly += (part.send args[:method]).translate(z:z)
			z+= part.height	+ args[:additional_spacing]
		end
		@assembly
	end

	def get_position_rec(obj, level=0)
		position = [0,0,0]
		return position if obj == nil
		obj.each do |o|
			o.transformations.each do |t|
				if t.class == Translate
					t.args[:x] ||= 0
					t.args[:y] ||= 0
					t.args[:z] ||= 0
					position[0] += t.args[:x]
					position[1] += t.args[:y]
					position[2] += t.args[:z]
				end
			end		
	#		puts "  " * level + position.inspect
			x,y,z = get_position_rec(o.children,level+1)
			position[0] += x
			position[1] += y
			position[2] += z
		end
		return position
	end

	#	this is experimental, does only work on simple parts. example:
	# The bolt head is on the -z plane, this will move it to "zero"
	def position(obj)
		get_position_rec(obj.children)
	end

end


