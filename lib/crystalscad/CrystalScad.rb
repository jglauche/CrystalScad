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
	include CrystalScad::Gears
	include CrystalScad::ScrewThreads
	include CrystalScad::PrintedThreads

	
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
		
		def save(filename,start_text=nil)
      file = File.open(filename,"w")
      file.puts start_text unless start_text == nil
      file.puts scad_output
      file.close		
		end

		def method_missing(meth, *args, &block)		
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

		def rotate_around(point,args)
			x,y,z= point.x, point.y, point.z
			self.translate(x:-x,y:-y,z:-z).rotate(args).translate(x:x,y:y,z:z)
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
			return RubyScadBridge.new.rotate(@args).gsub('"','')		
		end	
	end

 	class Translate < Transformation
		def to_rubyscad
			return RubyScadBridge.new.translate(@args).gsub('"','')		
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

		def center_xy
			@transformations << Translate.new({x:-@x/2,y:-@y/2})
			self
		end

		def center_x
			@transformations << Translate.new({x:-@x/2})
			self
		end

		def center_y
			@transformations << Translate.new({y:-@y/2})
			self
		end

		def center_z
			@transformations << Translate.new({z:-@z/2})
			self
		end

		def center
			@transformations << Translate.new({x:-@x/2,y:-@y/2,z:-@z/2})
			self
		end
	
		def to_rubyscad
			return RubyScadBridge.new.cube(@args)		
		end	
	end

	def cube(args={})
		if args.kind_of? Array
			args = {size:args}
		elsif args.kind_of? Hash
		  args[:x] ||= 0
		  args[:y] ||= 0
		  args[:z] ||= 0
		  args = {size:[args[:x],args[:y],args[:z]]}		
		end	
		Cube.new(args)	
	end
	
	class Sphere < Primitive
		def to_rubyscad	
			return RubyScadBridge.new.sphere(@args)		
		end	
	end

	def sphere(args)
		Sphere.new(args)		
	end
		
	class Polyhedron < Primitive
		def to_rubyscad	
			return RubyScadBridge.new.polyhedron(@args)		
		end			
	end

	def polyhedron(args)
		Polyhedron.new(args)
	end
	

	#	2d primitives
	class Square < Primitive
		def to_rubyscad
			return RubyScadBridge.new.square(@args)		
		end			
	end

	def square(args)
		if args.kind_of? Array
			args = {size:args}
		elsif args.kind_of? Hash
		  unless args[:size]
		    args[:x] ||= 0
		    args[:y] ||= 0
		    args = {size:[args[:x],args[:y]]}		
      end
		end
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
		if args.kind_of? Array
			r = self			
			args.each do |a|
				if a.respond_to? :show
					r = Union.new(r,a.show)	
				else
					r = Union.new(r,a)	
				end
			end
			r
		else
			Union.new(self,args)
		end		
	end

	def -(args)
		return args	 if self == nil		
		if args.kind_of? Array
			r = self			
			args.each do |a|
				if a.respond_to? :output
					r = Difference.new(r,a.output)	
				else	
					r = Difference.new(r,a)	
				end
			end
			r
		else
			Difference.new(self,args)
		end
	end
	
	def *(args)
		return args	 if self == nil		
		Intersection.new(self,args)
	end
	
	def hull(*parts)
	  Hull.new(*parts)	  
	end


	class Import < Primitive
		def initialize(filename)
			@transformations = []
			@filename = filename		
		end		
		
		def to_rubyscad	
			return RubyScadBridge.new.import("\""+@filename.to_s+"\"") # apparently the quotes get lost otherwise
		end	
	end

	def import(filename)
		Import.new(filename)
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
				attributes[:a] ||= 255
				
				r = attributes[:r].to_f / 255.0
				g = attributes[:g].to_f / 255.0
				b = attributes[:b].to_f / 255.0
				a = attributes[:a].to_f / 255.0
				attributes = [r,g,b,a]
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

	class Projection < CSGModifier
		def initialize(object, attributes)
			@operation = "projection"
			super(object, attributes)
		end
	end

	
	def color(args)
		return Color.new(self,args)		
	end

	def linear_extrude(args)
		if args[:h]	# rename to height
			args[:height] = args[:h]
			args.delete(:h)
		end
		args = args.collect { |k, v| "#{k} = #{v}" }.join(', ')
		return LinearExtrude.new(self,args)				
	end

	def rotate_extrude(args)
		if args[:h]	# rename to height
			args[:height] = args[:h]
			args.delete(:h)
		end
		args = args.collect { |k, v| "#{k} = #{v}" }.join(', ')
		return RotateExtrude.new(self,args)				
	end

	def projection(args={})
		args = args.collect { |k, v| "#{k} = #{v}" }.join(', ')
		return Projection.new(self,args)				
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

  # produces a hull() of 2 cylidners
  # accepts d,r,h for cylinder options
  # l long slot length
  def long_slot(args)
    hull(cylinder(d:args[:d],r:args[:r],h:args[:h]),cylinder(d:args[:d],r:args[:r],h:args[:h]).translate(x:args[:l]))    
  end
  
	def radians(a)
  	a/180.0 * Math::PI
	end
  
  def degrees(a)
	  a*180 /  Math::PI
  end

end


